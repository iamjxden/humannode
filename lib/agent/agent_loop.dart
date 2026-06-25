import 'dart:async';
import 'dart:convert';
import 'package:humannode/inference/inference_engine.dart';
import 'package:humannode/models/message.dart';
import 'package:humannode/config/app_config.dart';
import 'package:humannode/core/logger/humannode_logger.dart';
import 'agent_state.dart';
import 'agent_memory.dart';
import 'agent_prompt_builder.dart';
import 'tools/tool_registry.dart';
import 'tools/tool_result.dart';
import 'reflexion.dart';
import 'nudge.dart';

class AgentLoop {
  final InferenceEngine inferenceEngine;
  final ToolRegistry toolRegistry;
  final AgentMemory agentMemory;
  final AgentPromptBuilder agentPromptBuilder;
  final Reflexion reflexion = Reflexion();
  final Nudge nudge = Nudge();

  final _stateController = StreamController<AgentState>.broadcast();
  final _outputController = StreamController<String>.broadcast();
  final _toolCallController = StreamController<Map<String, dynamic>>.broadcast();

  AgentState _state = AgentState.idle;
  bool _interruptRequested = false;
  String _modelPath = '';
  int _stepCount = 0;
  int _maxSteps = AppConfig.maxAgentSteps;

  AgentLoop({
    required this.inferenceEngine,
    required this.toolRegistry,
    required this.agentMemory,
    required this.agentPromptBuilder,
  });

  Stream<AgentState> get stateStream => _stateController.stream;
  Stream<String> get outputStream => _outputController.stream;
  Stream<Map<String, dynamic>> get toolCallStream => _toolCallController.stream;
  AgentState get state => _state;
  int get stepCount => _stepCount;

  void setModel(String modelPath) => _modelPath = modelPath;
  void setMaxSteps(int steps) => _maxSteps = steps;

  Future<void> run(List<Message> messages) async {
    if (_modelPath.isEmpty) {
      if (!_outputController.isClosed) {
        _outputController.add('No model loaded. Please download and load a model first.');
      }
      _setState(AgentState.errored);
      return;
    }

    _interruptRequested = false;
    reflexion.reset();
    nudge.reset();
    toolRegistry.resetCallCounts();
    _stepCount = 0;
    _setState(AgentState.thinking);

    final msgMaps = messages
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    try {
      String prompt = await agentPromptBuilder.build(
        messages: msgMaps,
        agentMode: true,
      );

      while (!_interruptRequested && _stepCount < _maxSteps) {
        _setState(AgentState.thinking);
        final parsed = await _generateAndParse(prompt);
        if (_interruptRequested) break;
        if (parsed == null) {
          _setState(AgentState.errored);
          break;
        }

        switch (parsed['type'] as String) {
          case 'final_answer':
            final answer = parsed['content'] as String;
            agentMemory.add(Message.assistant(answer));
            if (!_outputController.isClosed) _outputController.add(answer);
            _setState(AgentState.idle);
            return;

          case 'text':
            final text = parsed['content'] as String;
            final nudgeMsg = nudge.nudge(text);
            if (nudgeMsg != null) {
              prompt = agentPromptBuilder.buildContinuation(nudgeMsg);
            } else {
              if (!_outputController.isClosed) _outputController.add(text);
              prompt = agentPromptBuilder.buildContinuation('');
            }
            _stepCount++;
            break;

          case 'tool_call':
            _setState(AgentState.acting);
            final name = parsed['name'] as String;
            final args = parsed['args'] as Map<String, dynamic>;

            if (!_toolCallController.isClosed) {
              _toolCallController.add({'name': name, 'args': args});
            }

            final stopwatch = Stopwatch()..start();
            final result = await toolRegistry.execute(name, args);
            stopwatch.stop();

            final resultStr = switch (result) {
              ToolSuccess<String>(data: final d) => d,
              ToolFailure(error: final e, detail: final d) =>
                  d != null && d.isNotEmpty ? '$e: $d' : e,
              ToolSuccess(data: final d) => d.toString(),
            };

            agentMemory.add(
              Message.toolResult(
                name: name,
                result: resultStr,
              ),
            );

            if (result is ToolFailure && reflexion.canRetry) {
              final correction = reflexion.correct(
                resultStr,
                jsonEncode({'name': name, 'args': args}),
              );
              prompt = agentPromptBuilder.buildContinuation(correction);
            } else {
              prompt = agentPromptBuilder.buildContinuation(resultStr);
            }
            _stepCount++;
            break;

          default:
            _stepCount++;
            break;
        }
      }

      if (_interruptRequested) {
        _setState(AgentState.interrupted);
        if (!_outputController.isClosed) {
          _outputController.add('\n[Agent interrupted by user]');
        }
      } else if (_stepCount >= _maxSteps) {
        _setState(AgentState.stopped);
        if (!_outputController.isClosed) {
          _outputController.add('\n[Maximum agent steps ($_maxSteps) reached]');
        }
      }
    } catch (e, st) {
      HumanNodeLogger.error('Agent loop crashed', e, st);
      _setState(AgentState.errored);
      if (!_outputController.isClosed) {
        _outputController.add('\n[Error: ${e.toString().truncate(200)}]');
      }
    }
  }

  Future<Map<String, dynamic>?> _generateAndParse(String prompt) async {
    final buffer = StringBuffer();
    final stopwatch = Stopwatch()..start();

    try {
      final stream = await inferenceEngine.generateStream(
        prompt,
        modelPath: _modelPath,
        predictTokens: 4096,
      );

      await for (final chunk in stream) {
        if (_interruptRequested) break;
        buffer.write(chunk);
        if (!_outputController.isClosed) _outputController.add(chunk);
      }
    } on InferenceException catch (e) {
      HumanNodeLogger.error('Inference failed in agent loop', e);
      if (!_outputController.isClosed) {
        _outputController.add('\n[Inference error: ${e.message}]');
      }
      return null;
    } catch (e) {
      HumanNodeLogger.error('Unexpected error in agent loop', e);
      return null;
    }

    stopwatch.stop();
    final text = buffer.toString();
    HumanNodeLogger.info(
      'Agent turn complete: ${text.length} chars, '
      '${stopwatch.elapsed.inMilliseconds}ms',
    );

    final finalMatch = RegExp(
      r'<final_answer>(.*?)</final_answer>',
      dotAll: true,
    ).firstMatch(text);

    if (finalMatch != null) {
      final content = finalMatch.group(1)?.trim() ?? text;
      return {'type': 'final_answer', 'content': content};
    }

    final toolMatches = RegExp(
      r'<tool_call>(.*?)</tool_call>',
      dotAll: true,
    ).allMatches(text).toList();

    if (toolMatches.isNotEmpty) {
      for (final match in toolMatches) {
        try {
          final jsonStr = match.group(1)!.trim();
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          if (json.containsKey('name') && json.containsKey('args')) {
            return {
              'type': 'tool_call',
              'name': json['name'] as String,
              'args': (json['args'] as Map<String, dynamic>?) ?? {},
            };
          }
        } on FormatException {
          HumanNodeLogger.warn('Failed to parse tool call JSON: ${match.group(1)}');
        }
      }
    }

    return {'type': 'text', 'content': text};
  }

  void _setState(AgentState newState) {
    if (_state == newState) return;
    _state = newState;
    if (!_stateController.isClosed) _stateController.add(newState);
  }

  void interrupt() {
    _interruptRequested = true;
    inferenceEngine.stop();
  }

  void dispose() {
    _stateController.close();
    _outputController.close();
    _toolCallController.close();
  }
}

extension _StringTruncate on String {
  String truncate(int maxLen) =>
      length <= maxLen ? this : '${substring(0, maxLen - 3)}...';
}
