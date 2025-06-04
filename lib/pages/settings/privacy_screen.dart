// lib/pages/privacy/privacy_screen.dart
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _isDataCollectionEnabled = true;
  bool _isPersonalizedAdsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: SizedBox(
          height: 80,
          child: Center(child: Image.asset('assets/logo.png', height: 80)),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 50)],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nastavitve zasebnosti',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 30),
            _buildPrivacyOption(
              title: 'Dovoli zbiranje podatkov',
              subtitle:
                  'Pomagajte nam izboljšati aplikacijo z dovoljenjem za anonimno zbiranje podatkov. Ti podatki se uporabljajo izključno za izboljšanje aplikacije.',
              trailing: Switch(
                value: _isDataCollectionEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isDataCollectionEnabled = value;
                  });
                  _showSnackBar(
                    context,
                    'Zbiranje podatkov je ' +
                        (value ? 'omogočeno' : 'onemogočeno'),
                  );
                },
                activeColor: AppColors.leafGreen,
                inactiveTrackColor: AppColors.leafGreen.withOpacity(0.5),
                inactiveThumbColor: AppColors.leafGreen,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Naša politika zasebnosti',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 15),
            _buildPolicySection(
              title: '1. Katere podatke zbiramo',
              content:
                  'Zbiramo osnovne analitične podatke (npr. uporabo aplikacije, poročila o napakah) za izboljšanje delovanja. NE zbiramo osebnih podatkov, kot so vaše ime, e-pošta ali natančna lokacija, brez vašega izrecnega soglasja.',
            ),
            const SizedBox(height: 10),
            _buildPolicySection(
              title: '2. Uporaba podatkov',
              content:
                  'Zbrani podatki se uporabljajo izključno za notranje analize za izboljšanje uporabniške izkušnje, odpravo napak in razvoj novih funkcij. Če so omogočeni personalizirani oglasi, se lahko podatki uporabijo za prikaz ustreznih oglasov.',
            ),
            const SizedBox(height: 10),
            _buildPolicySection(
              title: '3. Varnost podatkov',
              content:
                  'Uporabljamo standardne varnostne ukrepe za zaščito vaših podatkov pred nepooblaščenim dostopom, spremembo, razkritjem ali uničenjem. Vendar noben prenos po internetu ali elektronsko shranjevanje ni 100% varno.',
            ),
            const SizedBox(height: 10),
            _buildPolicySection(
              title: '4. Storitve tretjih oseb',
              content:
                  'Lahko uporabljamo storitve tretjih oseb (npr. ponudnike analitike, oglasna omrežja), ki lahko zbirajo podatke. Te storitve imajo svoje politike zasebnosti. Vaših osebnih podatkov ne delimo z njimi za trženjske namene brez vašega soglasja.',
            ),
            const SizedBox(height: 10),
            _buildPolicySection(
              title: '5. Vaše možnosti',
              content:
                  'V aplikaciji lahko upravljate nastavitve zasebnosti, vključno z izklopom zbiranja podatkov in personaliziranih oglasov. Prav tako imate pravico zahtevati vpogled v osebne podatke ali njihovo izbris.',
            ),
            const SizedBox(height: 10),
            _buildPolicySection(
              title: '6. Spremembe politike',
              content:
                  'Politiko zasebnosti lahko občasno posodobimo. Obvestili vas bomo z objavo nove različice. Nadaljnja uporaba pomeni, da se strinjate s spremembami.',
            ),
            const SizedBox(height: 10),
            _buildPolicySection(
              title: '7. Kontaktirajte nas',
              content:
                  'Če imate kakršnakoli vprašanja ali predloge glede zasebnosti, nas kontaktirajte na support@dishdash.com.',
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Zadnja posodobitev: 3. junij 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.charcoal.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOption({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.leafGreen,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.charcoal.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildPolicySection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.charcoal.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}