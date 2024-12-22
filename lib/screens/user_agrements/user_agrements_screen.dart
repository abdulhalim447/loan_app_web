import 'package:flutter/material.dart';

class LoanDetailsScreen extends StatefulWidget {
  const LoanDetailsScreen({Key? key}) : super(key: key);

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Agreements'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LoanTableWidget(),
            const SizedBox(height: 20),
            const LoanTextDetailsWidget(),
            const SizedBox(height: 20),
            const SignatureTableWidget(),
          ],
        ),
      ),
    );
  }
}

class LoanTableWidget extends StatelessWidget {
  const LoanTableWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: const [
        TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Borrower:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Uddin'),
          ),
        ]),
        TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Loan Time:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Dec 20, 2024, 01:33 PM'),
          ),
        ]),
        TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Contact Number:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('0000000000'),
          ),
        ]),
        TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Loan Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('200000'),
          ),
        ]),
        TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Loan Installments:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('24 Months'),
          ),
        ]),
        TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Monthly Interest Rate:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('3%'),
          ),
        ]),
        TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Payment Date:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('10th of every month'),
          ),
        ]),
      ],
    );
  }
}

class LoanTextDetailsWidget extends StatelessWidget {
  const LoanTextDetailsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Security:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
            'To protect Lender, the loan company working online different from another bank that\'s why Party A does not require collateral for this loan.',
        ),
        SizedBox(height: 16),
        Text(
          'Wrong Information:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'If Party B provides wrong bank information or ID information, then Party A should ask for a deposit from Party B 20% of the loan amount.',
        ),
        SizedBox(height: 16),
        Text(
          'Liabilities:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'If Party B is involved in any kind of illegal activities such as gambling, money laundering, etc., then Party A can take legal action.',
        ),
        SizedBox(height: 16),
        Text(
          'Default:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'If for any reason Borrower does not succeed in making any payment on time, Borrower shall be in default.',
        ),
      ],
    );
  }
}

class SignatureTableWidget extends StatelessWidget {
  const SignatureTableWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Borrower Signature:'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/borrower_signature.png', // Replace with your image path
              height: 100,
            ),
          ),
        ]),
        const TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Lender Signature:'),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox.shrink(),
          ),
        ]),
      ],
    );
  }
}
