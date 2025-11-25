class StudentSubject {
  final Subject subject;
  final Schedule schedule;
  final Instructor instructor;
  final Classroom classroom;

  StudentSubject({
    required this.subject,
    required this.schedule,
    required this.instructor,
    required this.classroom,
  });

  factory StudentSubject.fromJson(Map<String, dynamic> json) {
    return StudentSubject(
      subject: Subject.fromJson(json['subject'] ?? {}),
      schedule: Schedule.fromJson(json['schedule'] ?? {}),
      instructor: Instructor.fromJson(json['instructor'] ?? {}),
      classroom: Classroom.fromJson(json['classroom'] ?? {}),
    );
  }
}

class Subject {
  final int id;
  final String name;
  final String code;
  final String createdAt;
  final String updatedAt;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Subject',
      code: json['code'] ?? 'N/A',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class Schedule {
  final int id;
  final String timeIn;
  final String timeOut;
  final String dayOfWeek;

  Schedule({
    required this.id,
    required this.timeIn,
    required this.timeOut,
    required this.dayOfWeek,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? 0,
      timeIn: json['timeIn'] ?? 'TBA',
      timeOut: json['timeOut'] ?? 'TBA',
      dayOfWeek: json['dayOfWeek'] ?? 'TBA',
    );
  }
}

class Instructor {
  final int id;
  final String firstname;
  final String lastname;
  final String email;

  Instructor({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'] ?? 0,
      firstname: json['firstname'] ?? 'Unknown',
      lastname: json['lastname'] ?? 'Instructor',
      email: json['email'] ?? '',
    );
  }

  String get fullName => '$firstname $lastname';
}

class Classroom {
  final int id;
  final String name;
  final String createdAt;
  final String updatedAt;

  Classroom({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Room',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
