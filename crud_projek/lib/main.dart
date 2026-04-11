import 'package:flutter/material.dart';

void main() {
  runApp(const ReservationApp());
}

enum UserRole { admin, user }

class AppUser {
  const AppUser({
    required this.username,
    required this.password,
    required this.role,
    required this.displayName,
  });

  final String username;
  final String password;
  final UserRole role;
  final String displayName;
}

class Reservation {
  const Reservation({
    required this.id,
    required this.customerName,
    required this.sportField,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.createdBy,
  });

  final String id;
  final String customerName;
  final String sportField;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String note;
  final String createdBy;
}

class ReservationApp extends StatefulWidget {
  const ReservationApp({super.key});

  @override
  State<ReservationApp> createState() => _ReservationAppState();
}

class _ReservationAppState extends State<ReservationApp> {
  final List<AppUser> _users = const [
    AppUser(
      username: 'admin',
      password: 'admin123',
      role: UserRole.admin,
      displayName: 'Administrator',
    ),
    AppUser(
      username: 'user',
      password: 'user123',
      role: UserRole.user,
      displayName: 'Pengguna',
    ),
  ];

  final List<Reservation> _reservations = [
    Reservation(
      id: '1',
      customerName: 'Budi',
      sportField: 'Futsal A',
      date: DateTime.now(),
      startTime: const TimeOfDay(hour: 18, minute: 0),
      endTime: const TimeOfDay(hour: 19, minute: 0),
      note: 'Sparring',
      createdBy: 'user',
    ),
  ];

  AppUser? _activeUser;

  void _login(String username, String password) {
    final user = _users.where(
      (u) => u.username == username.trim() && u.password == password,
    );

    if (user.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username atau password salah")),
      );
      return;
    }

    setState(() {
      _activeUser = user.first;
    });
  }

  void _logout() {
    setState(() {
      _activeUser = null;
    });
  }

  void _addReservation(Reservation reservation) {
    setState(() {
      _reservations.add(reservation);
    });
  }

  void _deleteReservation(String id) {
    setState(() {
      _reservations.removeWhere((r) => r.id == id);
    });
  }

  void _updateReservation(Reservation reservation) {
    final index = _reservations.indexWhere((r) => r.id == reservation.id);
    if (index != -1) {
      setState(() {
        _reservations[index] = reservation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Reservasi Lapangan",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xfff4f6f8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      home: _activeUser == null
          ? LoginPage(onLogin: _login)
          : DashboardPage(
              user: _activeUser!,
              reservations: _reservations,
              users: _users,
              onLogout: _logout,
              onAdd: _addReservation,
              onDelete: _deleteReservation,
              onUpdate: _updateReservation,
            ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLogin});

  final Function(String, String) onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();

  void submit() {
    if (_formKey.currentState!.validate()) {
      widget.onLogin(username.text, password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff4caf50), Color(0xff2e7d32)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: 300,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sports_soccer,
                          size: 60, color: Colors.green),
                      const SizedBox(height: 10),
                      const Text(
                        "Reservasi Lapangan",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: username,
                        decoration:
                            const InputDecoration(labelText: "Username"),
                        validator: (v) =>
                            v!.isEmpty ? "Username wajib diisi" : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: password,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: "Password"),
                        validator: (v) =>
                            v!.isEmpty ? "Password wajib diisi" : null,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: submit,
                        child: const Text("Login"),
                      ),
                      const SizedBox(height: 10),
                      const Text("Admin: admin/admin123"),
                      const Text("User: user/user123"),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.user,
    required this.reservations,
    required this.users,
    required this.onLogout,
    required this.onAdd,
    required this.onDelete,
    required this.onUpdate,
  });

  final AppUser user;
  final List<Reservation> reservations;
  final List<AppUser> users;
  final VoidCallback onLogout;
  final Function(Reservation) onAdd;
  final Function(String) onDelete;
  final Function(Reservation) onUpdate;

  bool canModify(Reservation r) {
    if (user.role == UserRole.admin) return true;
    return r.createdBy == user.username;
  }

  String getDisplayName(String username) {
    final u = users.firstWhere(
      (e) => e.username == username,
      orElse: () => user,
    );
    return u.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🏟️ Jadwal Reservasi (${user.displayName})"),
        actions: [
          IconButton(onPressed: onLogout, icon: const Icon(Icons.logout))
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reservations.length,
        itemBuilder: (context, i) {
          final r = reservations[i];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.sports_soccer, color: Colors.green),
              title: Text("${r.sportField} - ${r.customerName}"),
              subtitle: Text(
                "📅 ${r.date.day}/${r.date.month}/${r.date.year}\n"
                "⏰ ${r.startTime.format(context)} - ${r.endTime.format(context)}\n"
                "👤 Pemesan: ${r.customerName}\n"
                "🛠️ Dibuat oleh: ${getDisplayName(r.createdBy)}",
              ),
              trailing: canModify(r)
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(r.id),
                    )
                  : null,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddReservationDialog(
              user: user,
              onSave: onAdd,
            ),
          );
        },
      ),
    );
  }
}

class AddReservationDialog extends StatefulWidget {
  const AddReservationDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  final AppUser user;
  final Function(Reservation) onSave;

  @override
  State<AddReservationDialog> createState() => _AddReservationDialogState();
}

class _AddReservationDialogState extends State<AddReservationDialog> {
  final name = TextEditingController();
  final field = TextEditingController();
  final note = TextEditingController();

  DateTime date = DateTime.now();
  TimeOfDay start = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay end = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();

    if (widget.user.role == UserRole.user) {
      name.text = widget.user.displayName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah Reservasi"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: name,
            readOnly: widget.user.role == UserRole.user,
            decoration: const InputDecoration(labelText: "Nama Pemesan"),
          ),
          TextField(
            controller: field,
            decoration: const InputDecoration(labelText: "Lapangan"),
          ),
          TextField(
            controller: note,
            decoration: const InputDecoration(labelText: "Catatan"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        FilledButton(
          onPressed: () {
            final reservation = Reservation(
              id: DateTime.now().toString(),
              customerName: name.text,
              sportField: field.text,
              date: date,
              startTime: start,
              endTime: end,
              note: note.text,
              createdBy: widget.user.username,
            );

            widget.onSave(reservation);
            Navigator.pop(context);
          },
          child: const Text("Simpan"),
        )
      ],
    );
  }
}