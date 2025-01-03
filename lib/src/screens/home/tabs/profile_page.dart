import 'package:al_quran_audio/src/screens/auth/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../api/appwrite/functions.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }
        if (snapshot.data == true) {
          return const Center(child: Text('User is logged in'));
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Get the best experience by logging in ->",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "You can save your favorite playlist to the cloud. And continue listening from where you left off. No need to worry about losing your playlist. We got you covered.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => const LoginPage());
                  },
                  iconAlignment: IconAlignment.end,
                  child: const Row(
                    children: [
                      Spacer(),
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.fast_forward_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
