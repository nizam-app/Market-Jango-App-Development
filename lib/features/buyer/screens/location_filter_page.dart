import 'package:flutter/material.dart';

class LocationFilterPage extends StatelessWidget {
  const LocationFilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? selectedCountry = 'Bangladesh';
    String? selectedCategory = 'Fashion';

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.32),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.4,
            child: Container(
              color: Colors.black,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Country Dropdown
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Your country"),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: selectedCountry,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFE9F2FF),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    items: ['Bangladesh', 'India', 'USA']
                        .map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    ))
                        .toList(),
                    onChanged: (value) {},
                  ),

                  const SizedBox(height: 20),

                  // Location Search Field
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Enter your Location"),
                  ),
                  const SizedBox(height: 5),
                  const TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search your location",
                      filled: true,
                      fillColor: Color(0xFFF3F6FA),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Category Dropdown
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Categories"),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFE9F2FF),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    items: ['Fashion', 'Electronics', 'Grocery']
                        .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                        .toList(),
                    onChanged: (value) {},
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
