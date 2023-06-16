import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomTable extends StatelessWidget {
  final List<List<String>> data;

  ///[borderLinesColor]this is the color of the verticall and horizantal lines in the table
  final Color borderLinesColor;

  ///[backgroundColor] Background Color of the table
  final Color backgroundColor;

  ///[titleTextColor]This is the color of the title text
  Color? titleTextColor; 

  ///[title]this is the text that describes the table content
  String? title;

  ///[radius] radius of the table corners
 final double radius;

 ///[showtitle] sets either to show table title or not show
 bool showtitle = false;


  CustomTable(
      {super.key, required this.data,
      required this.borderLinesColor,
      required this.backgroundColor,
      required this.radius,
      required this.showtitle,
      this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,borderRadius: BorderRadius.circular(radius??0)
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         showtitle? Padding(
            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 8),
            child: Text(
              title??'',
              style: TextStyle(
                  color: titleTextColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
            ),
          ): const SizedBox(),///if showtitle is set to false it will return sizedBox
          Table(
            border: TableBorder.all(color: borderLinesColor),
            children: _buildRows(),
          ),
        ],
      ),
    );
  }

  List<TableRow> _buildRows() {
    List<TableRow> rows = [];

    // Add header row
    rows.add(TableRow(
      children: data.first.map((item) => _buildHeaderCell(item)).toList(),
    ));

    // Add remaining rows
    for (int i = 1; i < data.length; i++) {
      rows.add(TableRow(
        children: data[i].map((item) => _buildCell(item)).toList(),
      ));
    }

    return rows;
  }
  ///header row
  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  ///other rows
  Widget _buildCell(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Text(text),
    );
  }
}
