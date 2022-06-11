// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/models/cart_model.dart';
import 'package:lapak/widget/custom_card.dart';
import 'package:lapak/widget/skeleton.dart';

class Keranjang extends StatefulWidget {
  const Keranjang({Key? key}) : super(key: key);

  @override
  State<Keranjang> createState() => _KeranjangState();
}

class _KeranjangState extends State<Keranjang> {
  late Cart cart;
  late Future getCart;
  @override
  void initState() {
    getCart = ApiService().getCart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width / 25),
          child: Column(
            children: [
              _header(width),
              SizedBox(
                height: width / 15,
              ),
              FutureBuilder(
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return StaggeredGrid.count(
                      mainAxisSpacing: 2,
                      crossAxisCount: 2,
                      children: [
                        Skeleton(
                        ),
                        Skeleton(
                        ),
                        Skeleton(
                        ),
                        Skeleton(
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("terjadi kesalahan"),
                    );
                  } else {
                    if (snapshot.hasData) {
                      return _card(width, snapshot.data);
                    } else {
                      return Center(
                        child: Text("kosong"),
                      );
                    }
                  }
                },
                future: getCart,
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget _header(width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Iconsax.arrow_left)),
        Text(
          "Keranjang",
          style: TextStyle(
            fontSize: width / 15,
            fontFamily: "popinsemi",
          ),
        ),
        Text(
          "Chat",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _card(width, Cart cart) {
    return StaggeredGrid.count(
      mainAxisSpacing: 2,
      crossAxisCount: 2,
      children: cart.data.map((data) {
        return CustomCard(
              data: data,
              where: "cart",
            );
      }).toList(),
    );
  }
}
