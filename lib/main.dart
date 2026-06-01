import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Selçuk Akıllı Ev Sistemi',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: SmartHomeCenter(),
    );
  }
}

class SmartHomeCenter extends StatefulWidget {
  @override
  _SmartHomeCenterState createState() => _SmartHomeCenterState();
}

class _SmartHomeCenterState extends State<SmartHomeCenter> {
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://projeadi-default-rtdb.firebaseio.com/',
  ).ref();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _dbRef.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          // Firebase'deki tüm verileri çekiyoruz
          Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          // Verileri güvenli bir şekilde değişkenlere atıyoruz
          bool yagmurVar = data['yagmur_durumu'] ?? false;
          bool gazKacagi = data['gaz_kacagi'] ?? false;
          int gazSeviyesi = data['gaz_seviyesi'] ?? 0;
          String vanaDurumu = data['vana_durumu'] ?? "ACIK";
          Map<dynamic, dynamic> odalarData = data['odalar'] ?? {};

          int salon = odalarData['salon'] ?? 0;
          int mutfak = odalarData['mutfak'] ?? 0;
          int yatakOdasi = odalarData['yatak_odasi'] ?? 0; // Firebase'de nasıl açtıysan birebir aynı yazmalısın
          int banyo = odalarData['banyo'] ?? 0;

          // Eğer gaz kaçağı varsa ekran kırmızı olsun
          Color anaRenk = gazKacagi ? Colors.red[900]! : (yagmurVar ? Colors.blueGrey[900]! : Colors.indigo[50]!);

          return Scaffold(
            backgroundColor: anaRenk,
            appBar: AppBar(
              title: Text("Akıllı Ev Kontrol Paneli"),
              centerTitle: true,
              backgroundColor: gazKacagi ? Colors.black : Colors.indigo,
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- GAZ KAÇAĞI UYARI PANELİ ---
                  if (gazKacagi) 
                    Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 40),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text("ACİL DURUM: GAZ KAÇAĞI ALGILANDI!", 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        ],
                      ),
                    ),

                  // --- GAZ SEVİYESİ KARTI ---
                  _buildStatusCard(
                    title: "Gaz Seviyesi",
                    value: "$gazSeviyesi",
                    subTitle: gazKacagi ? "Tehlikeli Seviye!" : "Normal",
                    icon: Icons.gas_meter,
                    iconColor: gazKacagi ? Colors.red : Colors.green,
                  ),

                  // --- YAĞMUR DURUMU KARTI ---
                  _buildStatusCard(
                    title: "Hava Durumu",
                    value: yagmurVar ? "Yağmurlu" : "Yağmur Yok",
                    subTitle: yagmurVar ? "Pencereleri Kapatın" : "Hava Açık",
                    icon: yagmurVar ? Icons.umbrella : Icons.cloud,
                    iconColor: yagmurVar ? Colors.blue : Colors.grey,
                  ),
                  // --- SICAKLIK KARTI ---
                  _buildStatusCard(
                    title: "Oda Sıcaklığı",
                    value: "${data['sicaklik']?.toStringAsFixed(1) ?? '0.0'} °C",
                    subTitle: "İç Mekan",
                    icon: Icons.thermostat,
                    iconColor: Colors.orange,
                  ),

                  // --- NEM KARTI ---
                  _buildStatusCard(
                    title: "Hava Nemi",
                    value: "% ${data['nem']?.toStringAsFixed(0) ?? '0'}",
                    subTitle: "Bağıl Nem",
                    icon: Icons.water_drop,
                    iconColor: Colors.blue,
                  ),

                  // --- VANA KONTROL KARTI ---
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: Icon(Icons.vibration, color: vanaDurumu == "KAPALI" ? Colors.red : Colors.green),
                      title: Text("Vana Durumu: $vanaDurumu"),
                      subtitle: Text("Manuel Kontrol"),
                      trailing: Switch(
                        value: vanaDurumu == "ACIK",
                        onChanged: (bool newValue) {
                          // Firebase'e vana komutu gönderiyoruz
                          _dbRef.update({
                            "vana_durumu": newValue ? "ACIK" : "KAPALI"
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Ev Aydınlatma Sistemi",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),

                  // 1. SALON KONTROL KARTI
                  Card(
                    color: Colors.white.withOpacity(0.1),
                    child: ListTile(
                      leading: Icon(
                        Icons.lightbulb,
                        color: salon == 1 ? Colors.amber : Colors.grey,
                        size: 30,
                      ),
                      title: const Text("Salon Lambası", style: TextStyle(color: Colors.white)),
                      subtitle: Text(salon == 1 ? "Açık" : "Kapalı", style: const TextStyle(color: Colors.white70)),
                      trailing: Switch(
                        value: salon == 1,
                        onChanged: (yeniDeger) {
                          // Firebase'deki odalar/salon değerini doğrudan güncelliyoruz
                          _dbRef.child('odalar/salon').set(yeniDeger ? 1 : 0);
                        },
                      ),
                    ),
                  ),

                  // 2. MUTFAK KONTROL KARTI
                  Card(
                   color: Colors.white.withOpacity(0.1),
                   child: ListTile(
                     leading: Icon(
                        Icons.lightbulb,
                        color: mutfak == 1 ? Colors.amber : Colors.grey,
                        size: 30,
                      ),
                      title: const Text("Mutfak Lambası", style: TextStyle(color: Colors.white)),
                      subtitle: Text(mutfak == 1 ? "Açık" : "Kapalı", style: const TextStyle(color: Colors.white70)),
                      trailing: Switch(
                        value: mutfak == 1,
                        onChanged: (yeniDeger) {
                          _dbRef.child('odalar/mutfak').set(yeniDeger ? 1 : 0);
                        },
                      ),
                    ),
                  ),

                  // 3. YATAK ODASI KONTROL KARTI
                  Card(
                    color: Colors.white.withOpacity(0.1),
                    child: ListTile(
                      leading: Icon(
                        Icons.lightbulb,
                        color: yatakOdasi == 1 ? Colors.amber : Colors.grey,
                        size: 30,
                      ),
                      title: const Text("Yatak Odası Lambası", style: TextStyle(color: Colors.white)),
                      subtitle: Text(yatakOdasi == 1 ? "Açık" : "Kapalı", style: const TextStyle(color: Colors.white70)),
                      trailing: Switch(
                        value: yatakOdasi == 1,
                        onChanged: (yeniDeger) {
                          _dbRef.child('odalar/yatak_odasi').set(yeniDeger ? 1 : 0);
                        },
                      ),
                    ),
                  ),

                  // 4. BANYO KONTROL KARTI
                  Card(
                    color: Colors.white.withOpacity(0.1),
                    child: ListTile(
                      leading: Icon(
                        Icons.lightbulb,
                        color: banyo == 1 ? Colors.amber : Colors.grey,
                        size: 30,
                      ),
                      title: const Text("Banyo Lambası", style: TextStyle(color: Colors.white)),
                      subtitle: Text(banyo == 1 ? "Açık" : "Kapalı", style: const TextStyle(color: Colors.white70)),
                      trailing: Switch(
                        value: banyo == 1,
                        onChanged: (yeniDeger) {
                          _dbRef.child('odalar/banyo').set(yeniDeger ? 1 : 0);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
            ),
          );
        }

        // Veri beklerken yükleme ekranı
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  // Şık kartlar oluşturmak için yardımcı fonksiyon
  Widget _buildStatusCard({required String title, required String value, required String subTitle, required IconData icon, required Color iconColor}) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, color: iconColor),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text(subTitle, style: TextStyle(color: iconColor, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}