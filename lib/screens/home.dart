import 'package:flutter/material.dart';
import 'package:ja_paguei/helpers/expense_helper.dart';
import 'package:ja_paguei/models/expense.dart';
import 'package:ja_paguei/screens/add_expense.dart';
import 'package:ja_paguei/widgets/custom_alert_dialog.dart';
import 'package:ja_paguei/widgets/custom_expense_card.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Expense> listExpense = [];
  int totalItems = 0;
  final String empty = "assets/images/empty.png";

  @override
  void initState() {
    getAllListExpense();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _showExpensePage();
            },
            icon: const Icon(Icons.add),
            tooltip: "Adicionar",
          )
        ],
        title: const Text('Minhas Contas'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Expanded(
            child: listExpense.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Image.asset(empty),
                      ),
                      const Text("No momento sua lista esta vazia!",
                          style: TextStyle(
                              fontSize: 14, fontStyle: FontStyle.normal)),
                    ],
                  )
                : ListView.builder(
                    shrinkWrap: false,
                    itemCount: listExpense.length,
                    itemBuilder: (context, index) {
                      return ExpenseCard(
                        expense: listExpense[index],
                        onDelete: _onDeleteExpense,
                        onEdit: _onEditExpense,
                      );
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total de contas: $totalItems",
                style:
                    const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return CustomAlertDialog(
                            title: "Pagar tudo?",
                            description:
                                "Deseja realmente pagar todas as suas contas?",
                            onPlay: _onPayEverything,
                            validatePop: true,
                          );
                        });
                  },
                  child: const Text("Pagar tudo")),
            ],
          )
        ]),
      ),
    );
  }

  void getAllListExpense() async {
    ExpenseHelper.instance.getAllExpense().then((value) {
      setState(() {
        listExpense = value;
        totalItems = listExpense.length;
      });
    });
  }

  void _showExpensePage({Expense? expense}) async {
    final reExpense = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddExpense(
            expense: expense,
          ),
        ));

    if (reExpense != null) {
      if (expense != null) {
        await ExpenseHelper.instance.updateExpense(reExpense);
      } else {
        await ExpenseHelper.instance.saveExpense(reExpense);
      }
    }

    getAllListExpense();
  }

  void _onDeleteExpense(int id) async {
    ExpenseHelper.instance.deleteExpense(id).then((value) {
      getAllListExpense();
    });
  }

  void _onEditExpense(Expense? expense) {
    _showExpensePage(expense: expense);
  }

  void _onPayEverything() {
    ExpenseHelper.instance.deleteAll();
    getAllListExpense();
  }
}
