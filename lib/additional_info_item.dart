import 'package:flutter/material.dart';

//card weater forcast function   //data is initinised by constructor
class AdditionalInfoItem extends StatelessWidget {
  //data is initinised by constructor - icon , label,value
  final IconData icon;
  final String label;
  final String value;
  
  const AdditionalInfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,

  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          //this 'icon' - will give power to set here icon acc to yourself
          icon,
          size: 32,
        ),
        const SizedBox(height: 8),
        //similerly here this 'label' - will give power to set humidity or else acc to yourself
        Text(label),
        const SizedBox(height: 8),
        Text(
          //this 'value' - will give power to set value acc to yourself for weather or may be temperature
          value,
          style:const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
