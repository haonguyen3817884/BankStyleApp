import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const Contact(
            title: "Contact",
            customerFontFamily: "SF Pro Display",
            customerFontStyle: FontStyle.normal));
  }
}

class Contact extends StatefulWidget {
  const Contact(
      {Key? key,
      required this.title,
      required this.customerFontFamily,
      required this.customerFontStyle})
      : super(key: key);

  final String title;
  final String customerFontFamily;
  final FontStyle customerFontStyle;

  @override
  State<Contact> createState() => _ContactState();
}

Future<List<dynamic>> contactData() async {
  String endPoint = "https://mocki.io/v1/49698a5a-61eb-4ac8-9d40-cf93c6aa1923";
  var response = await http
      .get(Uri.parse(endPoint), headers: {'Content-Type': 'application/json'});
  String data = convert.utf8.decode(response.bodyBytes);
  List<dynamic> decodedData = convert.jsonDecode(data);
  return decodedData;
}

TextStyle customerTextStyle(double fontSize, String fontFamily,
    FontStyle fontStyle, FontWeight fontWeight, Color textColor) {
  return TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontStyle: fontStyle,
      fontWeight: fontWeight,
      color: textColor);
}

Widget customerText(
    dynamic text,
    double customerTextFontSize,
    FontStyle customerTextFontStyle,
    String customerTextFontFamily,
    Color customerTextColor,
    FontWeight customerTextFontWeight) {
  return Text('$text',
      style: TextStyle(
          color: customerTextColor,
          fontSize: customerTextFontSize,
          fontStyle: customerTextFontStyle,
          fontFamily: customerTextFontFamily,
          fontWeight: customerTextFontWeight));
}

Widget customerBoxWidget(
    double customerBoxHeight,
    Color customerBoxFillColor,
    Color customerBoxCheckColor,
    Color customerBoxActiveColor,
    bool customerBoxValue,
    Function customerBoxOnChange,
    String customerBoxName) {
  return Container(
      height: customerBoxHeight,
      width: 24.8,
      child: Transform.scale(
          scale: 1.1,
          child: Checkbox(
              activeColor: customerBoxActiveColor,
              checkColor: customerBoxCheckColor,
              fillColor: MaterialStateProperty.all(customerBoxFillColor),
              value: customerBoxValue,
              onChanged: (bool? value) {
                customerBoxOnChange(customerBoxName, value);
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
      decoration: BoxDecoration(
          color: const Color(0xFFB2D0CE),
          border: Border.all(
              color: Colors.black, style: BorderStyle.solid, width: 1.7),
          borderRadius: const BorderRadius.all(Radius.circular(7.4))));
}

Widget getContactPlace(
    String customerName,
    String customerImage,
    textFontStyle,
    textFontFamily,
    String customerCity,
    Function customerPress,
    BuildContext context,
    Widget contactRight) {
  return Container(
      child: GestureDetector(
          child: Card(
              child: Row(children: <Widget>[
                Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(customerImage)),
                        borderRadius: BorderRadius.circular(43))),
                const SizedBox(width: 17),
                Expanded(
                    child: Column(children: <Widget>[
                  Row(children: <Widget>[
                    Text(customerName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontStyle: textFontStyle,
                            fontFamily: textFontFamily,
                            fontWeight: FontWeight.w500)),
                    const Expanded(child: SizedBox()),
                    contactRight
                  ]),
                  const SizedBox(height: 5),
                  Row(children: <Widget>[
                    Text(customerCity,
                        style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF79767D),
                            fontStyle: textFontStyle,
                            fontFamily: textFontFamily,
                            fontWeight: FontWeight.w400)),
                    SizedBox(
                        height: 15,
                        child: ElevatedButton(
                            child: const Text("place"),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CustomerPlace(
                                          customerName: customerName)));
                            }))
                  ])
                ]))
              ]),
              color: Colors.transparent,
              elevation: 0.0),
          onLongPress: () {
            customerPress();
          }),
      margin: const EdgeInsets.only(bottom: 29.5, top: 0));
}

List<Widget> contactWidgetsFilledData(
    String textFontFamily,
    FontStyle textFontStyle,
    Function getBoxWidgets,
    List<dynamic> customerData,
    String placeName,
    BuildContext context,
    Function updateAllContactPlace) {
  List<Widget> contactPlaces = <Widget>[];

  for (var i = 0; i < customerData.length; ++i) {
    var customer = customerData[i];
    String customerName = customer["name"];
    String customerImage = customer["avatar"];
    dynamic customerAge;
    String customerCity = "";
    bool isCustomerIn = customer["isIn"];
    Widget contactRight;

    Function customerPress = () {};

    if ("" == customer["city"]) {
      customerCity = "undefined";
    } else {
      customerCity = customer["city"];
    }

    if (null == customer["age"] || 0 == customer["age"]) {
      customerAge = "No Information";
    } else {
      customerAge = customer["age"];
    }

    if ("contactBoxWidgets" == placeName) {
      contactRight = customerBoxWidget(24.8, Colors.transparent, Colors.black,
          Colors.blue, isCustomerIn, updateAllContactPlace, customerName);
    } else {
      contactRight = customerText(customerAge, 12, textFontStyle,
          textFontFamily, const Color(0xFF79767D), FontWeight.w400);
      customerPress = getBoxWidgets;
    }
    Widget contactPlace = getContactPlace(
        customerName,
        customerImage,
        textFontStyle,
        textFontFamily,
        customerCity,
        customerPress,
        context,
        contactRight);

    contactPlaces.add(contactPlace);
  }
  return contactPlaces;
}

class _ContactState extends State<Contact> {
  List<dynamic> _contacts = [];

  String _placeName = "contactWidgets";

  String _contactTitle = "";

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() async {
    List<dynamic> contacts = await contactData();

    for (var i = 0; i < contacts.length; ++i) {
      contacts[i]["isIn"] = false;
    }

    setState(() {
      _contacts = contacts;
    });

    setState(() {
      _contactTitle = widget.title;
    });

    setState(() {
      _placeName = "contactWidgets";
    });
  }

  void getBoxWidgets() {
    setState(() {
      _placeName = "contactBoxWidgets";
    });

    updateContactTitlePlace();
  }

  List<Widget> getContactWidgets(
      List<dynamic> data, BuildContext context, String placeName) {
    List<Widget> contactWidgets = contactWidgetsFilledData(
        widget.customerFontFamily,
        widget.customerFontStyle,
        getBoxWidgets,
        data,
        placeName,
        context,
        updateAllContactPlace);
    return contactWidgets;
  }

  void updateBoxContact(String customerName, bool isCustomerIn) {
    var contacts = _contacts;

    for (var i = 0; i < contacts.length; ++i) {
      var customerContact = contacts[i];
      if (customerName == customerContact["name"]) {
        contacts[i]["isIn"] = isCustomerIn;
      }
    }

    setState(() {
      _contacts = contacts;
    });
  }

  int getCustomerIsIn() {
    int count = 0;
    var contacts = _contacts;
    for (var i = 0; i < contacts.length; ++i) {
      var customerContact = contacts[i];
      if (customerContact["isIn"]) {
        count = count + 1;
      }
    }

    return count;
  }

  void updateContactTitlePlace() {
    int customerIsIn = getCustomerIsIn();

    String customerTitle = customerIsIn.toString();

    setState(() {
      _contactTitle = customerTitle + " " + "items";
    });
  }

  void updateAllContactPlace(String customerName, bool isCustomerIn) {
    updateBoxContact(customerName, isCustomerIn);
    updateContactTitlePlace();
  }

  Widget renderContactWidgets(BuildContext context) {
    return Column(children: <Widget>[
      Container(
          child: Column(children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(top: 32, right: 20, left: 24),
                child: Text("Contacts",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontStyle: widget.customerFontStyle,
                        fontFamily: widget.customerFontFamily,
                        fontWeight: FontWeight.w400))),
            Padding(
                padding: const EdgeInsets.only(
                    top: 33, right: 20, left: 18, bottom: 0),
                child: Column(
                    children:
                        getContactWidgets(_contacts, context, _placeName)))
          ], crossAxisAlignment: CrossAxisAlignment.start),
          decoration: BoxDecoration(
              color: const Color(0xFF282729),
              borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(top: 14))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(_contactTitle,
                style: TextStyle(
                    fontFamily: widget.customerFontFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontStyle: widget.customerFontStyle)),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 19),
                onPressed: () => {getData()}),
            centerTitle: true,
            systemOverlayStyle:
                const SystemUiOverlayStyle(statusBarColor: Color(0xFF1E1F1F)),
            backgroundColor: Colors.transparent,
            elevation: 0.0),
        body: Container(
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(child: child, scale: animation);
                },
                child: _placeName == "contactBoxWidgets"
                    ? renderContactWidgets(context)
                    : SizedBox(child: renderContactWidgets(context))),
            decoration: const BoxDecoration(color: Colors.transparent)),
        backgroundColor: const Color(0xFF1E1F1F));
  }
}

class CustomerPlace extends StatefulWidget {
  const CustomerPlace({Key? key, required this.customerName}) : super(key: key);

  final String customerName;

  @override
  State<CustomerPlace> createState() => _CustomerPlaceState();
}

class _CustomerPlaceState extends State<CustomerPlace> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Customer Detail"),
            centerTitle: true,
            systemOverlayStyle:
                const SystemUiOverlayStyle(statusBarColor: Color(0xFF1E1F1F)),
            backgroundColor: Colors.transparent,
            elevation: 0.0),
        body: Center(
            child: Container(
                child: Column(
                    children: <Widget>[Text(widget.customerName)],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center),
                decoration: const BoxDecoration(color: Colors.transparent))),
        backgroundColor: const Color(0xFF1E1F1F));
  }
}
