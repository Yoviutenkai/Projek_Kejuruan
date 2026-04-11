import 'package:flutter/material.dart';

void main() {
  runApp(const ReservationApp());
}

// GlobalKey untuk menangani SnackBar agar tidak error context
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

enum UserRole { admin, user }

class AppUser {
  const AppUser({
    required this.username,
    required this.password,
    required this.role,
    required this.displayName,
  });
  final String username, password, displayName;
  final UserRole role;
}

class Reservation {
  Reservation({
    required this.id,
    required this.customerName,
    required this.sportField,
    required this.note,
    required this.createdBy,
  });
  final String id;
  String customerName;
  String sportField;
  String note;
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
      password: '123',
      role: UserRole.admin,
      displayName: 'Admin Lapangan',
    ),
    AppUser(
      username: 'user',
      password: '123',
      role: UserRole.user,
      displayName: 'Eko (Pelanggan)',
    ),
  ];

  final List<Reservation> _reservations = [
    Reservation(
      id: '1',
      customerName: 'Budi',
      sportField: 'Futsal A',
      note: 'Lunas',
      createdBy: 'admin',
    ),
  ];

  AppUser? _activeUser;

  void _login(String user, String pass) {
    final found = _users.where((u) => u.username == user && u.password == pass);
    if (found.isEmpty) {
      messengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text("Login Gagal!")),
      );
    } else {
      setState(() => _activeUser = found.first);
    }
  }

  // --- FUNGSI CRUD ---
  void _add(Reservation r) => setState(() => _reservations.add(r));

  void _delete(String id) =>
      setState(() => _reservations.removeWhere((r) => r.id == id));

  void _update(String id, String newField, String newNote) {
    final index = _reservations.indexWhere((r) => r.id == id);
    if (index != -1) {
      setState(() {
        _reservations[index].sportField = newField;
        _reservations[index].note = newNote;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: _activeUser == null
          ? LoginPage(onLogin: _login)
          : DashboardPage(
              user: _activeUser!,
              data: _reservations,
              onLogout: () => setState(() => _activeUser = null),
              onAdd: _add,
              onDelete: _delete,
              onUpdate: _update,
            ),
    );
  }
}

// --- HALAMAN LOGIN ---
class LoginPage extends StatelessWidget {
  LoginPage({super.key, required this.onLogin});
  final Function(String, String) onLogin;
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sports_tennis, size: 50, color: Colors.green),
                const Text(
                  "Login Reservasi",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: userCtrl,
                  decoration: const InputDecoration(labelText: "Username"),
                ),
                TextField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => onLogin(userCtrl.text, passCtrl.text),
                  child: const Text("Masuk"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- HALAMAN DASHBOARD (READ & DELETE) ---
class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.user,
    required this.data,
    required this.onLogout,
    required this.onAdd,
    required this.onDelete,
    required this.onUpdate,
  });
  final AppUser user;
  final List<Reservation> data;
  final VoidCallback onLogout;
  final Function(Reservation) onAdd;
  final Function(String) onDelete;
  final Function(String, String, String) onUpdate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard ${user.displayName}"),
        actions: [
          IconButton(onPressed: onLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (ctx, i) {
          final r = data[i];
          final bool isOwner =
              user.role == UserRole.admin || r.createdBy == user.username;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: ListTile(
              title: Text(r.sportField),
              subtitle: Text("Pemesan: ${r.customerName}\nCatatan: ${r.note}"),
              trailing: isOwner
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditDialog(ctx, r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onDelete(r.id),
                        ),
                      ],
                    )
                  : const Icon(Icons.lock_outline),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final f = TextEditingController();
    final n = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tambah Reservasi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: f,
              decoration: const InputDecoration(labelText: "Nama Lapangan"),
            ),
            TextField(
              controller: n,
              decoration: const InputDecoration(labelText: "Catatan"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              onAdd(
                Reservation(
                  id: DateTime.now().toString(),
                  customerName: user.displayName,
                  sportField: f.text,
                  note: n.text,
                  createdBy: user.username,
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Reservation r) {
    final f = TextEditingController(text: r.sportField);
    final n = TextEditingController(text: r.note);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Reservasi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: f,
              decoration: const InputDecoration(labelText: "Nama Lapangan"),
            ),
            TextField(
              controller: n,
              decoration: const InputDecoration(labelText: "Catatan"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              onUpdate(r.id, f.text, n.text);
              Navigator.pop(ctx);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
