import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String userName;

  const Header({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'AI Trainer Pro | Welcome, $userName!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage: const AssetImage('assets/images/avatar.png'),
          ),
        ],
      ),
    );
  }
}
