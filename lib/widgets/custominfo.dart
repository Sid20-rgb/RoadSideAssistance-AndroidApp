import 'package:flutter/material.dart';

class CustomInfoWindow extends StatelessWidget {
   final String address;

  const CustomInfoWindow({required this.address});


   @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Adjust the width as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            address,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}