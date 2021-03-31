import 'package:flutter/material.dart';
import 'package:flutter_app/utils/MyNavigator.dart';
import 'package:flutter_app/utils/App.dart';
import 'package:flutter_app/widgets/Walkthrough.dart';

class Introduction extends StatefulWidget {
  @override
  _IntroductionState createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  final PageController controller = new PageController();

  int currentPage = 0;
  bool lastPage = false;

  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
      if (currentPage == 3) {
        lastPage = true;
      } else {
        lastPage = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: App.primaryColorDark,
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 3,
            child: PageView(
              children: <Widget>[
                Walkthrough(
                  title: App.wt1,
                  content: App.wc1,
                  imageIcon: Icons.phone_android,
                ),
                Walkthrough(
                  title: App.wt2,
                  content: App.wc1,
                  imageIcon: Icons.security,
                ),
                Walkthrough(
                  title: App.wt3,
                  content: App.wc1,
                  imageIcon: Icons.chat,
                ),
                Walkthrough(
                  title: App.wt4,
                  content: App.wc1,
                  imageIcon: Icons.backup,
                ),
              ],
              controller: controller,
              onPageChanged: _onPageChanged,
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  child: Text(lastPage ? "" : App.skip,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0)),
                  onPressed: () =>
                  lastPage ? null : MyNavigator.goToSignIn(context),
                ),
                FlatButton(
                  child: Text(lastPage ? App.gotIt : App.next,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0)),
                  onPressed: () => lastPage
                      ? MyNavigator.goToSignIn(context)
                      : controller.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
