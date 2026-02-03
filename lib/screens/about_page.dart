import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.aboutHowAiTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                  theme.colorScheme.tertiary.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          // Decorative background elements
          Positioned(
            top: 100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.secondary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content with combined liquid glass effect
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 60), // Space for app bar
                  // Single combined glass card with ALL content
                  LiquidGlass(
                    settings: const LiquidGlassSettings(
                      thickness: 8,
                      glassColor: Color(0x1AFFFFFF),
                      lightIntensity: 1.2,
                      blend: 30,
                    ),
                    shape: const LiquidRoundedSuperellipse(
                      borderRadius: Radius.circular(30),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Avatar
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.surface.withValues(alpha: 0.1),
                            ),
                            child: const CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage('assets/icon//hao_avatar.png'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Main content
                          Column(
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  AppLocalizations.of(context)!.aboutHowdyAgent,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  AppLocalizations.of(context)!.aboutPocketCompanion,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)!.aboutBio,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
                          // Contact section (now inside the same glass)
                          const SizedBox(height: 20),
                          Container(
                            child: Column(
                              children: [
                                Text.rich(
                                  TextSpan(
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: AppLocalizations.of(context)!.aboutIdeasInvite,
                                      ),
                                      TextSpan(
                                        text: AppLocalizations.of(context)!.aboutLetsMakeBetter,
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            final uri = Uri.parse('mailto:support@haoyu.io');
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(uri);
                                            }
                                          },
                                      ),
                                      TextSpan(
                                        text: AppLocalizations.of(context)!.aboutBotsEnjoyRide,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    AppLocalizations.of(context)!.aboutFriendlyDev,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action buttons
                  FilledButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse('https://buymeacoffee.com/hao_yu');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.coffee_rounded),
                    label: const Text('Buy Me a Coffee ☕'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.gotIt),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.aboutBuiltWith,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
