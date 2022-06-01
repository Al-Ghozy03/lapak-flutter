// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/pages/checkout/checkout.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/custom_route.dart';
import 'package:lapak/widget/rupiah_format.dart';

class Detail extends StatefulWidget {
  final data;
  Detail({required this.data});
  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(width/25),
        width: width,
        child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(CustomPageRoute(
                  child: Checkout(
                data: widget.data,
              )));
            },
            style: ElevatedButton.styleFrom(
                primary: blueTheme,
                padding: EdgeInsets.symmetric(vertical: width / 80),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width / 50))),
            child: Text(
              "Pesan",
              style: TextStyle(fontSize: width / 20, fontFamily: "popinsemi"),
            )),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 0,
              snap: true,
              backgroundColor: Colors.white,
              floating: true,
              stretch: true,
              leading: Container(
                width: width / 10,
                height: width / 10,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(100)),
                child: IconButton(
                  icon: Icon(Iconsax.arrow_left),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              expandedHeight: width / 1.1,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  widget.data.fotoBarang,
                  fit: BoxFit.cover,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(height / 10),
                child: Transform.translate(
                  offset: Offset(0, 1),
                  child: Container(
                    height: width / 7,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35)),
                        color: Colors.white),
                    child: Center(
                      child: Container(
                        width: width / 2,
                        height: width / 80,
                        decoration: BoxDecoration(
                            color: Color(0xffC4C4C4),
                            borderRadius: BorderRadius.circular(width)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                Container(
                  padding: EdgeInsets.all(width / 25),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              widget.data.namaBarang,
                              style: TextStyle(
                                  fontSize: width / 18,
                                  fontFamily: "popinsemi"),
                            ),
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Iconsax.message,
                                size: width / 20,
                              )),
                        ],
                      ),
                      SizedBox(
                        height: width / 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _info(
                                  width,
                                  CurrencyFormat.convertToIdr(
                                      widget.data.harga, 0),
                                  Iconsax.dollar_square),
                              SizedBox(
                                height: width / 60,
                              ),
                              _info(
                                  width, widget.data.daerah, Iconsax.location),
                            ],
                          ),
                          CircleAvatar(
                            backgroundImage: NetworkImage(widget.data.fotoToko),
                          )
                        ],
                      ),
                      SizedBox(
                        height: width / 40,
                      ),
                      Text(
                        widget.data.deskripsi,
                        style: TextStyle(fontSize: width / 30),
                      ),
                      SizedBox(
                        height: width / 20,
                      ),
                    ],
                  ),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _info(width, text, icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: grayText,
          size: width / 22,
        ),
        SizedBox(
          width: width / 50,
        ),
        Text(
          text,
          style: TextStyle(color: grayText, fontSize: width / 30),
        )
      ],
    );
  }
}
