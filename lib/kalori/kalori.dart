import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:piring_baru/bloc/nav/bottom_nav.dart';
import 'package:piring_baru/kalori/tambah.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:piring_baru/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Kalori extends StatefulWidget {
  const Kalori({super.key});

  @override
  State<Kalori> createState() => _KaloriState();
}

class _KaloriState extends State<Kalori> {
  List<dynamic> articles2 = [];
  final Map<String, List<Map<String, dynamic>>> groupedData = {};
  double totalEnergi = 0.0;
  String Id = '';
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String clientId = "PKL2023";
  String clientSecret = "PKLSERU";
  String tokenUrl =
      "https://apem.esolusindo.com/API/Token/token"; // Ganti dengan URL token endpoint Anda

  String accessToken = "";

  @override
  void initState() {
    super.initState();
    loadUserDataAndFetchData();
    fetchData2();
  }

  Future<void> fetchData2() async {
    final Uri apiUrl2 =
        Uri.parse('https://isipiringku.esolusindo.com/api/JadwalMakan/jadwal');
    final response = await http.get(apiUrl2);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> responseList = data['response'];
      setState(() {
        articles2 = responseList;
      });
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<void> getToken() async {
    try {
      // Buat permintaan untuk mendapatkan token menggunakan client_credentials
      var response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> tokenData = jsonDecode(response.body);
        accessToken = tokenData['access_token'];
        print('Token Akses: $accessToken');
      } else {
        // Handle error, misalnya, menampilkan pesan kesalahan
        print('Gagal mendapatkan token: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exception, misalnya, menampilkan pesan kesalahan
      print('Gagal mendapatkan token: $e');
    }
  }

  Future<void> loadUserDataAndFetchData() async {
    await loadUserData(); // Menunggu hingga loadUserData selesai
    fetchData(); // Panggil fetchData setelah Id diisi
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      final userData = UserData.fromJson(json.decode(userDataString));
      print(userData.nama);

      setState(() {
        Id = userData.idUser.toString();
      });
    }
  }

  List<dynamic> data = [];

  Future<void> fetchData() async {
    if (Id.isEmpty) {
      // Pastikan Id tidak kosong sebelum membuat permintaan http
      return;
    }

    print(Id);
    String fetkal =
        "https://isipiringku.esolusindo.com/api/Makanan/konsumsi?id_user=$Id&waktu=$formattedDate";
    final response = await http.get(
      Uri.parse(fetkal),
    );

    print(fetkal);
    print(Id);

    if (response.statusCode == 200) {
      print(Uri.parse);
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);

      setState(() {
        data = jsonResponse['response'];

        // Hitung total energi
        totalEnergi = data
            .map((item) => double.parse(item['energi']))
            .fold(0.0, (prev, curr) => prev + curr); // Change 0 to 0.0
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(selected: 1),
      body: SingleChildScrollView(
        child: Stack(children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/head2.jpg'),
                    fit: BoxFit.cover)),
          ),
          SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.only(top: 64)),
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.height * 0.4,
                              height: 30,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 250, 154, 0),
                                    Color.fromARGB(255, 246, 80, 20),
                                    Color.fromARGB(255, 235, 38, 16),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: kElevationToShadow[1],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 0,
                              ),
                              child: const Center(
                                child: Text(
                                  'Kalori Harian',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 15),
                            child: Row(children: [
                              const Icon(
                                Icons.calendar_month,
                                color: Colors.redAccent,
                                size: 30,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: 100,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  formattedDate,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ]),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: const Text(
                                    'Budget Kalori Harian\n1800 Kkal',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 229, 222, 156),
                                      borderRadius: BorderRadius.circular(10)),
                                  child:
                                      // ignore: unnecessary_null_comparison
                                      totalEnergi == 0
                                          ? CircularProgressIndicator()
                                          : Text(
                                              "${totalEnergi.toInt()} Kkal",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 350,
                            child: ListView(
                              children: articles2.map((article2) {
                                final String imageUrl2 = article2['gambar'];
                                final String judul2 = article2['nama'];
                                print(imageUrl2);

                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Image.network(
                                          imageUrl2,
                                          width:
                                              100, // Sesuaikan dengan ukuran gambar yang Anda inginkan
                                          height:
                                              50, // Sesuaikan dengan ukuran gambar yang Anda inginkan
                                        ),
                                        SizedBox(width: 16),
                                        Text(
                                          judul2,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          Container(
                            // Tinggi container
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                ),
                                Center(
                                    child: ElevatedButton(
                                        onPressed: () {
                                          data.forEach((item) {
                                            final namaMakanan =
                                                item['nama_makanan'];
                                            if (!groupedData
                                                .containsKey(namaMakanan)) {
                                              groupedData[namaMakanan] = [item];
                                            } else {
                                              groupedData[namaMakanan]
                                                  ?.add(item);
                                            }
                                          });
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                  'Riwayat Hari Ini',
                                                  textAlign: TextAlign.center,
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    children: groupedData
                                                        .entries
                                                        .map((entry) {
                                                      final namaMakanan =
                                                          entry.key;
                                                      final makananList =
                                                          entry.value;
                                                      final jumlahMakanan =
                                                          makananList.length;
                                                      final totalEnergi = makananList
                                                          .map((item) =>
                                                              double.parse(item[
                                                                  'energi']))
                                                          .fold(
                                                              0.0,
                                                              (prev, curr) =>
                                                                  prev + curr);

                                                      return ListTile(
                                                        title: Text(
                                                            '$namaMakanan (x$jumlahMakanan)'),
                                                        subtitle: Text(
                                                            'Total Energi: ${totalEnergi.toInt()}'),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  Text(
                                                      'Total Energi: ${totalEnergi.toInt()}'),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('Tutup'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Text('Riwayat Hari Ini')))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ]),
      ),
    );
  }
}
