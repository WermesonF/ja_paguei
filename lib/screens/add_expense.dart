import 'package:flutter/material.dart';
import 'package:currency_textfield/currency_textfield.dart';
import 'package:intl/intl.dart';
import 'package:ja_paguei/models/expense.dart';
import 'package:ja_paguei/widgets/custom_alert_dialog.dart';

class AddExpense extends StatefulWidget {
  AddExpense({Key? key, this.expense}) : super(key: key);

  Expense? expense;

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final String add = "assets/images/add.png";

  final CurrencyTextFieldController _controllerMoney =
      CurrencyTextFieldController(
          rightSymbol: "R\$", decimalSymbol: ".", thousandSymbol: ",");
  final TextEditingController _controllerTitle = TextEditingController();

  final _fromKey = GlobalKey<FormState>();

  Expense? _editExpense;

  @override
  void initState() {
    super.initState();

    if (widget.expense == null) {
      _editExpense = Expense();
    } else {
      _editExpense = Expense.fromMap(widget.expense!.toMap());
      _controllerTitle.text = _editExpense!.title.toString();
      _controllerMoney.text = _editExpense!.cost!.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(validExpense() ? "Nova Conta" : "Editar Conta"),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Form(
                  key: _fromKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _controllerTitle,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Preencha o título, para continuar.";
                          }
                        },
                        decoration: const InputDecoration(
                          label: Text("Conta"),
                          hintText: "Ex: Boleto água",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _controllerMoney,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Preencha o valor, para continuar.";
                          }
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          label: Text("Valor"),
                          hintText: "Ex: 100,00",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Image.asset(add),
                ),
                const SizedBox(
                  height: 20,
                ),
                Builder(builder: (context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    child: ElevatedButton(
                        onPressed: () {
                          if (_fromKey.currentState!.validate()) {
                            addExpense(_controllerTitle.text,
                                _controllerMoney.doubleValue,);
                          }
                        },
                        child: Text(validExpense() ? "Adicionar" : "Alterar")),
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool validExpense() {
    if (widget.expense == null) {
      //new expense
      return true;
    } else {
      //edit expense
      return false;
    }
  }

  void addExpense(String title, double cost,) {
    String? date = DateFormat("dd/MM/yyyy").format(DateTime.now());

    _editExpense!.title = title;
    _editExpense!.cost = cost;
    _editExpense!.date = date;

    showSnackBar(validExpense()
        ? "Conta adicionada com sucesso!"
        : "Conta editada com sucesso!");

    Navigator.pop(context, _editExpense);
  }

  Future<bool> _requestPop() async {
    if(!validExpense()) {
      showDialog(context: context, builder: (context) {
        return CustomAlertDialog(title: "Descartar alterações?", description: "Se sair as alterações serão perdidas.", validatePop: false,);
      });

      return false;
    } else {
      return true;
    }
  }

  void showSnackBar(String mensagen) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(mensagen),
    ));
  }
}
