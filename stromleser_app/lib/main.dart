import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async'; 
import 'dart:math'; 

void main() {
  runApp(const StromleserApp());
}

class StromleserApp extends StatelessWidget {
  const StromleserApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const StromleserHomePage(),
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor:const Color(0xFF1F1F1F),
      ),
    );
  }
}

class StromleserHomePage extends StatefulWidget {
  const StromleserHomePage({super.key});
  
  @override
  _StromleserHomePageState createState() => _StromleserHomePageState();
}

class _StromleserHomePageState extends State<StromleserHomePage> {
  late String formattedDate;
  int consumptionValue = 0;
  bool isPowerOn = false;
  bool isTimerActive = false;
  int totalConsumption = 0;

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  void togglePower() {
    setState(() {
      isPowerOn = !isPowerOn;
      if (isPowerOn) {
        startReadingSensor();
      } else {
        // to reset consum vals when powered off
        consumptionValue = 0;
        totalConsumption = 0;
      }
    });
  }

  void startReadingSensor() {
    if (isPowerOn) {
      // get the consum vals and update it /sec
      consumptionValue = getSensorValue();
      Future.delayed(const Duration(seconds: 1), () {
        if (isPowerOn) {
          setState(() {
            consumptionValue = getSensorValue();
          });
          startReadingSensor();
        }
      });
    }
  }

  int getSensorValue() {
    // rand no generator to act in for getting consum vals for eg. purposes
    return Random().nextInt(100); 
  }

  void toggleTimer() {
    if (isPowerOn && !isTimerActive) { // timer can only activate when the power is on
      setState(() {
        isTimerActive = true;
        totalConsumption = 0; // to reset tot consum when the timer is turneed off
      });
      startTimer();
    }
  }

  void startTimer() {
    if (isTimerActive) {
      // to record the vals for the next 10 sec fo timer activation
      int duration = 10; 
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (duration > 0) {
          setState(() {
            totalConsumption += consumptionValue; // updating the tot cons val
          });
          duration--;
        } else {
          timer.cancel(); 
          setState(() {
            isTimerActive = false; // reset timer status
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {},
        ),
        title: const Text('Stromleser'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              isPowerOn ? Icons.power : Icons.power_off,
              size: 100,
              color: isPowerOn ? Colors.green : Colors.white,
            ),
            const SizedBox(height: 20),
            // Power and Timer buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildControlButton(
                  Icons.power_settings_new,
                  'Power',
                  togglePower,
                  isActive: isPowerOn,
                ),
                buildControlButton(
                  Icons.timer,
                  'Timer',
                  toggleTimer,
                  isActive: isTimerActive,
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white54),
            const SizedBox(height: 20),
            // Energy Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Energy',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white54),
                    const SizedBox(width: 5),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Consumption Value
            const Text(
              'Live Consumption',
              style: TextStyle(fontSize: 18, color: Colors.white54),
            ),
            const SizedBox(height: 10),
            Text(
              '$consumptionValue', 
              style: const TextStyle(fontSize: 48, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Total Consumption (last 10s)',
              style: TextStyle(fontSize: 18, color: Colors.white54),
            ),
            const SizedBox(height: 10),
            Text(
              '$totalConsumption',
              style: const TextStyle(fontSize: 48, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // helper widget
  Widget buildControlButton(IconData icon, String label, VoidCallback onPressed, {required bool isActive}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey[800],
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Icon(icon, size: 30, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white54),
        ),
      ],
    );
  }
}