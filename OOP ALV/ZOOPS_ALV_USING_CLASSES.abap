*&---------------------------------------------------------------------*
*& Report ZOOPS_ALV_USING_CLASSES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zoops_alv_using_classes.

DATA: BEGIN OF vbrk_str,
        vbeln TYPE vbrk-vbeln,
        vsbed TYPE vbrk-vsbed,
      END OF vbrk_str,
      it_vbrks            LIKE TABLE OF vbrk_str,
      wa_vbrk             LIKE LINE OF it_vbrks,
      lo_custom_container TYPE REF TO cl_gui_custom_container,
      lo_alv_grid         TYPE REF TO cl_gui_alv_grid,
      it_fieldcatalog     TYPE lvc_t_fcat,
      wa_fieldcatalog     TYPE lvc_s_fcat.


PARAMETERS: org TYPE vbrk-vkorg.

CALL SCREEN 100.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'BACK'.
* SET TITLEBAR 'xxx'.
  CREATE OBJECT lo_custom_container
    EXPORTING
      container_name              = 'CUSTOM_CONTAINER_1'          " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      cntl_error                  = 1                       " CNTL_ERROR
      cntl_system_error           = 2                       " CNTL_SYSTEM_ERROR
      create_error                = 3                       " CREATE_ERROR
      lifetime_error              = 4                       " LIFETIME_ERROR
      lifetime_dynpro_dynpro_link = 5                       " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.

  CREATE OBJECT lo_alv_grid
    EXPORTING
      i_parent          = lo_custom_container                " Parent Container
    EXCEPTIONS
      error_cntl_create = 1                       " Error when creating the control
      error_cntl_init   = 2                       " Error While Initializing Control
      error_cntl_link   = 3                       " Error While Linking Control
      error_dp_create   = 4                       " Error While Creating DataProvider Control
      OTHERS            = 5.
  IF lo_alv_grid IS BOUND.
    PERFORM get_data.
    PERFORM create_fieldcat.
    PERFORM display.
  ENDIF.


ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.


FORM get_data.
  SELECT vbeln, vsbed
    FROM vbrk
    WHERE vkorg = @org
    INTO CORRESPONDING FIELDS OF TABLE @it_vbrks
    UP TO 200 ROWS.
ENDFORM.
FORM create_fieldcat.
  wa_fieldcatalog = VALUE #( col_pos = '1'
                             fieldname = 'VBELN').
  APPEND wa_fieldcatalog TO it_fieldcatalog.
  wa_fieldcatalog = VALUE #( col_pos = '2'
                           fieldname = 'VSBED').
  APPEND wa_fieldcatalog TO it_fieldcatalog.
ENDFORM.

FORM display.

  CALL METHOD lo_alv_grid->set_table_for_first_display
    CHANGING
      it_outtab                     = it_vbrks
      it_fieldcatalog               = it_fieldcatalog
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
ENDFORM.