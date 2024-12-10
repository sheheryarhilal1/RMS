import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttServerClient? client;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  String chilledWaterInTemp = '25';
  String chilledWaterOutTemp = '25';
  String suctionTemp = '25';
  String suctionHighTemp = '30';
  String suctionLowTemp = '20';
  String dischargeTemp = '35';
  String dischargeHighTemp = '40';
  String dischargeLowTemp = '30';
  String additionalTemp = '28';
  String additionalHighTemp = '33';
  String additionalLowTemp = '23';

  String mqttBroker = "test.mosquitto.org";
  String clientId = "flutter_mqtt_client2";
  int port = 1883;
  String publishStatus = "";

  // Map to store high and low values for each title
  final Map<String, Map<String, String>> _containerValues = {
    'Chilled water in': {'High': '25', 'Low': '15'},
    'Chilled water out': {'High': '26', 'Low': '16'},
    'Suction temp': {'High': '30', 'Low': '20'},
    'Discharge temp': {'High': '40', 'Low': '30'},
    'Additional temp': {'High': '33', 'Low': '23'},
  };

  ConnectCallback? _onConnected;

  @override
  void initState() {
    super.initState();
    _setupMqttClient();
    _connectMqtt();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              const SizedBox(height: 30),

              // Containers with icons, text, and subtitles on left and right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard(
                    icon: Icons.lightbulb,
                    color: Colors.blue,
                    title: 'Load 1',
                    subtitle: 'Temperature: $chilledWaterInTemp',
                    onTap: () => _showTemperatureDialog(
                      context,
                      'Chilled water in',
                      chilledWaterInTemp,
                      (newTemp) {
                        setState(() {
                          chilledWaterInTemp = newTemp;
                        });
                      },
                    ),
                  ),
                  _buildInfoCard(
                    icon: Icons.lightbulb,
                    color: Colors.orange,
                    title: 'Load 2',
                    subtitle: 'Temperature: $chilledWaterOutTemp',
                    onTap: () => _showTemperatureDialog(
                      context,
                      'Chilled water out',
                      chilledWaterOutTemp,
                      (newTemp) {
                        setState(() {
                          chilledWaterOutTemp = newTemp;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard(
                    icon: Icons.screenshot_monitor_rounded,
                    color: Colors.green,
                    title: 'LED TV',
                    subtitle:
                        'Temperature: $suctionTemp\nHigh: $suctionHighTemp\nLow: $suctionLowTemp',
                    onTap: () => _showSuctionDischargeTempDialog(
                      context,
                      'Suction temp',
                      suctionTemp,
                      suctionHighTemp,
                      suctionLowTemp,
                      (temp, highTemp, lowTemp) {
                        setState(() {
                          suctionTemp = temp;
                          suctionHighTemp = highTemp;
                          suctionLowTemp = lowTemp;
                        });
                      },
                    ),
                  ),
                  _buildInfoCard(
                    icon: Icons.dehaze,
                    color: Colors.purple,
                    title: 'Damper',
                    subtitle:
                        'Temperature: $dischargeTemp\nHigh: $dischargeHighTemp\nLow: $dischargeLowTemp',
                    onTap: () => _showSuctionDischargeTempDialog(
                      context,
                      'Discharge temp',
                      dischargeTemp,
                      dischargeHighTemp,
                      dischargeLowTemp,
                      (temp, highTemp, lowTemp) {
                        setState(() {
                          dischargeTemp = temp;
                          dischargeHighTemp = highTemp;
                          dischargeLowTemp = lowTemp;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // New row with additional containers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard(
                    icon: Icons.monitor_sharp,
                    color: Colors.cyan,
                    title: 'Curtain',
                    subtitle:
                        'Temperature: $additionalTemp\nHigh: $additionalHighTemp\nLow: $additionalLowTemp',
                    onTap: () => _showSuctionDischargeTempDialog(
                      context,
                      'Damper',
                      additionalTemp,
                      additionalHighTemp,
                      additionalLowTemp,
                      (temp, highTemp, lowTemp) {
                        setState(() {
                          additionalTemp = temp;
                          additionalHighTemp = highTemp;
                          additionalLowTemp = lowTemp;
                        });
                      },
                    ),
                  ),
                  _buildInfoCard(
                    icon: Icons.shutter_speed_rounded,
                    color: Colors.teal,
                    title: 'Shutter',
                    subtitle:
                        'Temperature: $additionalTemp\nHigh: $additionalHighTemp\nLow: $additionalLowTemp',
                    onTap: () => _showSuctionDischargeTempDialog(
                      context,
                      'Extra temp',
                      additionalTemp,
                      additionalHighTemp,
                      additionalLowTemp,
                      (temp, highTemp, lowTemp) {
                        setState(() {
                          additionalTemp = temp;
                          additionalHighTemp = highTemp;
                          additionalLowTemp = lowTemp;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }

  // Reusable info card widget with onTap
  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        width: MediaQuery.of(context).size.width * 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  Future<void> _connectMqtt() async {
    try {
      await client?.connect();
      print('Connected');
    } catch (e) {
      print('Exception: $e');
      client?.disconnect();
    }
  }

  void _setupMqttClient() {
    client = MqttServerClient(mqttBroker, clientId);
    client?.port = port;
    client?.logging(on: true);
    client?.onDisconnected = _onDisconnected;
    client?.onConnected = _onConnected;
    client?.onSubscribed = _onSubscribed;
  }

  void _onDisconnected() {
    print('Disconnected from MQTT broker.');
  }

  void _publishMessage(String topic, String message, {bool retain = false}) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client?.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!,
        retain: retain);
  }

  _showTemperatureDialog(BuildContext context, String title, String currentTemp,
      Function(String temp) onSave) {
    TextEditingController tempController =
        TextEditingController(text: currentTemp);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update $title'),
          content: TextField(
            controller: tempController,
            decoration: InputDecoration(labelText: 'Temperature'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newTemp = tempController.text;
                onSave(newTemp);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  _showSuctionDischargeTempDialog(
      BuildContext context,
      String title,
      String currentTemp,
      String currentHighTemp,
      String currentLowTemp,
      Function(String temp, String highTemp, String lowTemp) onSave) {
    TextEditingController tempController =
        TextEditingController(text: currentTemp);
    TextEditingController highTempController =
        TextEditingController(text: currentHighTemp);
    TextEditingController lowTempController =
        TextEditingController(text: currentLowTemp);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update $title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tempController,
                decoration: InputDecoration(labelText: 'Temperature'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: highTempController,
                decoration: InputDecoration(labelText: 'High Temperature'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: lowTempController,
                decoration: InputDecoration(labelText: 'Low Temperature'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String temp = tempController.text;
                String highTemp = highTempController.text;
                String lowTemp = lowTempController.text;
                onSave(temp, highTemp, lowTemp);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
