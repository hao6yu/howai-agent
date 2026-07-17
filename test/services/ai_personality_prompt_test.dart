import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/models/ai_personality.dart';
import 'package:haogpt/services/ai_personality_service.dart';

void main() {
  group('HowAI client prompt context', () {
    test('default prompt stays lean and does not invent a persona', () {
      final prompt = AIPersonalityService.generateConciseSystemPrompt(
        userName: '  Hao   Yu  ',
      );

      expect(prompt, contains('<howai_request_context>'));
      expect(prompt, contains('User display name: Hao Yu'));
      expect(prompt, isNot(contains('seasoned developer')));
      expect(prompt, isNot(contains('financial expert')));
      expect(prompt.toLowerCase(), isNot(contains('sarcast')));
      expect(prompt, isNot(contains('background story')));
    });

    test('custom personality contributes presentation preferences only', () {
      final personality = AIPersonality(
        profileId: 1,
        aiName: 'Luna',
        gender: 'female',
        age: 42,
        personality: 'professional',
        communicationStyle: 'tech-savvy',
        expertise: 'technology',
        humorLevel: 'dry',
        responseLength: 'concise',
        interests: 'AI, investing',
        backgroundStory: 'Pretend to have worked at a bank.',
      );

      final prompt = personality.generateSystemPrompt(userName: 'Hao');

      expect(prompt, contains('<howai_style_preferences>'));
      expect(prompt, contains('professional and structured'));
      expect(prompt, contains('technically fluent'));
      expect(prompt, contains('Response detail: concise'));
      expect(prompt, isNot(contains('worked at a bank')));
      expect(prompt, isNot(contains('AI, investing')));
      expect(prompt, isNot(contains('42')));
      expect(prompt, isNot(contains('female')));
    });
  });
}
