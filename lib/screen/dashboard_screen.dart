import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tugas_akhir/localization/app_localization.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Failed to load a banner ad: ${error.message}');
          ad.dispose();
        },
      ),
    )..load();

    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (error) {
          print('Failed to load an interstitial ad: ${error.message}');
        },
      ),
    );

    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
        },
        onAdFailedToLoad: (error) {
          print('Failed to load a rewarded ad: ${error.message}');
        },
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _showInterstitialAd() {
    if (_isInterstitialAdReady) {
      _interstitialAd?.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
    } else {
      print('Interstitial ad is not ready yet.');
    }
  }

  void _showRewardedAd() {
    if (_isRewardedAdReady) {
      _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          print('Reward earned: ${reward.amount} ${reward.type}');
        },
      );
      _rewardedAd = null;
      _isRewardedAdReady = false;
    } else {
      print('Rewarded ad is not ready yet.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Informasi tentang aplikasi',
              child: Text(
                loc.translate('app_description'),
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            Text(loc.translate('support_us')),
            ElevatedButton(
              onPressed: _showInterstitialAd,
              child: Text(loc.translate('show_interstitial_ads')),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showRewardedAd,
              child: Text(loc.translate('show_rewarded_ads')),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _isBannerAdReady
          ? Container(
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            )
          : SizedBox.shrink(),
    );
  }
}
