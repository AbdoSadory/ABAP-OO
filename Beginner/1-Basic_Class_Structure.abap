*&---------------------------------------------------------------------*
*& Report zoop_course_udemy
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zoop_course_udemy.

*1. Basic Class Structure
*Create class ZCL_PERSON with:
*Attributes: name, age, address (private)
*Constructor to initialize attributes
*Getter/setter methods
*Method display_info() to output details

CLASS zcl_person DEFINITION.
  PUBLIC SECTION.
    METHODS:      constructor IMPORTING name    TYPE string
                                        age     TYPE n
                                        address TYPE string,
      display_data.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: name    TYPE string,
          age(3)  TYPE n,
          address TYPE string.
ENDCLASS.


CLASS zcl_person IMPLEMENTATION.
  METHOD constructor.
    me->name = name.
    me->age = age.
    me->address = address.
  ENDMETHOD.

  METHOD display_data.
    WRITE:|{ me->name }, { me->age }, { me->address }|.
  ENDMETHOD.
ENDCLASS.


DATA: person TYPE REF TO zcl_person.

START-OF-SELECTION.
  CREATE OBJECT person
    EXPORTING
      name    = 'CR7'
      age     = '39'
      address = 'Nasr City-KSA'.

  CALL METHOD person->display_data.