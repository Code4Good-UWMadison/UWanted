enum Skill {
  Backend,
  Frontend,
  AIML,
  Data,
  App,
  Others,
}

class Skills {
  bool backend;
  bool frontend;
  bool aiml;
  bool data;
  bool app;
  bool others;

  Skills(
      {this.backend = false,
      this.frontend = false,
      this.aiml = false,
      this.data = false,
      this.app = false,
      this.others = false});

  Skills.clone(Skills skills)
      : this(
          backend: skills.backend,
          frontend: skills.frontend,
          aiml: skills.aiml,
          data: skills.data,
          app: skills.app,
          others: skills.others,
        );

  void set(String skill, bool bool) {
    switch (skill) {
      case 'Backend':
        this.backend = bool;
        break;
      case 'Frontend':
        this.frontend = bool;
        break;
      case 'AI&ML':
        this.aiml = bool;
        break;
      case 'Data':
        this.data = bool;
        break;
      case 'App':
        this.app = bool;
        break;
      case 'Others':
        this.others = bool;
        break;
      default:
    }
  }

  bool get(String skill) {
    switch (skill) {
      case 'Backend':
        return this.backend;
        break;
      case 'Frontend':
        return this.frontend;
        break;
      case 'AI&ML':
        return this.aiml;
        break;
      case 'Data':
        return this.data;
        break;
      case 'App':
        return this.app;
        break;
      case 'Others':
        return this.others;
        break;
      default:
        return null;
    }
  }

  @override
  String toString() {
    String str = '';
    str += (this.backend ? 'Backend, ' : '') +
        (this.frontend ? 'Frontend, ' : '') +
        (this.aiml ? 'AI&ML, ' : '') +
        (this.data ? 'Data, ' : '') +
        (this.app ? 'APP, ' : '') +
        (this.others ? 'Others, ' : '');
    return str.length > 0 ? str.substring(0, str.length - 2) : str;
  }
}
