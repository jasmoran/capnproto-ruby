@0xdbb9ad1f14bf0b36;

struct Person {
  name @0 :Text;
  birthdate @3 :Int32;

  email @1 :Text;
  phones @2 :Int16 = 8;
}

struct Date {
  year @0 :Int16;
  month @1 :UInt8;
  day @2 :UInt8;
}

const bob :Person = (name = "Bob", email = "bob@example.com", birthdate = -2, phones = 3);
