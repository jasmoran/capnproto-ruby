@0xdbb9ad1f14bf0b36;

struct Person {
  name @0 :Text;
  birthdate @3 :Date;

  email @1 :Text;
  phones @2 :Int16 = 8;
}

struct Date {
  year @0 :Int16;
  month @1 :UInt8;
  day @2 :UInt8;
}

const bob :Person = (
  name = "Bob",
  email = "bob@example.com",
  birthdate = (year = 1980, month = 6, day = 1),
  phones = 3
);
