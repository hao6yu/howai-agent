import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../screens/subscription_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionGuard extends StatefulWidget {
  final Widget child;

  const SubscriptionGuard({Key? key, required this.child}) : super(key: key);

  @override
  State<SubscriptionGuard> createState() => _SubscriptionGuardState();
}

class _SubscriptionGuardState extends State<SubscriptionGuard> {
  bool _showPaywall = false;
  bool _isCheckingAccess = true;

  static const String _firstLaunchTimeKey = 'first_launch_time';
  static const int _freeTrialDurationDays = 14;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      final isSubscribed = await subscriptionService.checkSubscriptionStatus();

      if (isSubscribed) {
        if (!mounted) return;
        setState(() {
          _showPaywall = false;
          _isCheckingAccess = false;
        });
        return;
      }

      final inFreeTrial = await _isInFreeTrial();

      if (!mounted) return;
      setState(() {
        _showPaywall = !inFreeTrial;
        _isCheckingAccess = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _showPaywall = true; // Default to paywall on error, not free access
        _isCheckingAccess = false;
      });
    }
  }

  Future<bool> _isInFreeTrial() async {
    final prefs = await SharedPreferences.getInstance();

    int? firstLaunchTime = prefs.getInt(_firstLaunchTimeKey);
    if (firstLaunchTime == null) {
      firstLaunchTime = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_firstLaunchTimeKey, firstLaunchTime);
      return true;
    }

    final firstLaunchDate = DateTime.fromMillisecondsSinceEpoch(firstLaunchTime);
    final difference = DateTime.now().difference(firstLaunchDate).inDays;

    return difference < _freeTrialDurationDays;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        if (_isCheckingAccess || subscriptionService.isLoading) {
          return const ColoredBox(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show the child if subscribed or not showing paywall yet
        if (subscriptionService.isSubscribed || !_showPaywall) {
          return widget.child;
        }

        // Otherwise show subscription screen
        return SubscriptionScreen(
          onSubscribed: () {
            setState(() {
              _showPaywall = false;
            });
          },
        );
      },
    );
  }
}
