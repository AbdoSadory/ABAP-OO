*&---------------------------------------------------------------------*
*& Report ZOOPS_ALV_USING_SPLITTER_CL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zoops_alv_using_splitter_cl.

DATA: BEGIN OF vbrk_str,
        vbeln TYPE vbrk-vbeln,
        knumv TYPE vbrk-knumv,
      END OF vbrk_str,
      it_vbrks            LIKE TABLE OF vbrk_str,
      wa_vbrk             LIKE LINE OF it_vbrks,
      BEGIN OF prcd_str,
        knumv TYPE PRCD_ELEMENTS-knumv,
        kbetr TYPE PRCD_ELEMENTS-kbetr,
      END OF prcd_str,
      it_conditions            LIKE TABLE OF prcd_str,
      wa_condition             LIKE LINE OF it_conditions,
      lo_custom_container TYPE REF TO cl_gui_custom_container,
      lo_splitter         TYPE REF TO cl_gui_splitter_container,
      lo_left_container   TYPE REF TO cl_gui_container,
      lo_right_container  TYPE REF TO cl_gui_container,
      lo_left_alv_grid    TYPE REF TO cl_gui_alv_grid,
      lo_right_alv_grid   TYPE REF TO cl_gui_alv_grid,
      it_fieldcatalog_vbrk     TYPE lvc_t_fcat,
      wa_fieldcatalog_vbrk     TYPE lvc_s_fcat,
      it_fieldcatalog_condition     TYPE lvc_t_fcat,
      wa_fieldcatalog_condition     TYPE lvc_s_fcat,
      wa_layout           TYPE lvc_s_layo.

PARAMETERS: org TYPE vbrk-vkorg.
CALL SCREEN 100.
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
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'BACK'.

  CREATE OBJECT lo_custom_container
    EXPORTING
      container_name              = 'UPPER_CONTAINER'          " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      cntl_error                  = 1                       " CNTL_ERROR
      cntl_system_error           = 2                       " CNTL_SYSTEM_ERROR
      create_error                = 3                       " CREATE_ERROR
      lifetime_error              = 4                       " LIFETIME_ERROR
      lifetime_dynpro_dynpro_link = 5                       " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.

  IF lo_custom_container IS BOUND.
    CREATE OBJECT lo_splitter
      EXPORTING
        parent            = lo_custom_container                  " Parent Container
        rows              = 1                    " Number of Rows to be displayed
        columns           = 2                 " Number of Columns to be Displayed
      EXCEPTIONS
        cntl_error        = 1                       " See Superclass
        cntl_system_error = 2                       " See Superclass
        OTHERS            = 3.
    IF lo_splitter IS BOUND.
      CALL METHOD lo_splitter->set_column_width
        EXPORTING
          id                = 1     " Column ID
          width             = 5  " NPlWidth
        EXCEPTIONS
          cntl_error        = 1      " See CL_GUI_CONTROL
          cntl_system_error = 2      " See CL_GUI_CONTROL
          OTHERS            = 3.
      CALL METHOD lo_splitter->set_column_width
        EXPORTING
          id                = 2     " Column ID
          width             = 5  " NPlWidth
        EXCEPTIONS
          cntl_error        = 1      " See CL_GUI_CONTROL
          cntl_system_error = 2      " See CL_GUI_CONTROL
          OTHERS            = 3.

      CALL METHOD lo_splitter->get_container(
        EXPORTING
          row       = 1       " Row
          column    = 1    " Column
        RECEIVING
          container = lo_left_container   " Container
      ).
      CALL METHOD lo_splitter->get_container(
        EXPORTING
          row       = 1       " Row
          column    = 2    " Column
        RECEIVING
          container = lo_right_container   " Container
      ).

      PERFORM get_data.
      PERFORM create_fieldcat.
      PERFORM display.
    ENDIF.
  ENDIF.
ENDMODULE.


FORM get_data.
  SELECT vbeln, knumv
    FROM vbrk
    WHERE vkorg = @org and FKDAT >= @( |{ '20240101' }| )
    INTO CORRESPONDING FIELDS OF TABLE @it_vbrks
    UP TO 200 ROWS.

  select KNUMV, KBETR
    from PRCD_ELEMENTS
    FOR ALL ENTRIES IN @it_vbrks
    where knumv = @it_vbrks-knumv
    into CORRESPONDING FIELDS OF TABLE @it_conditions.

ENDFORM.
FORM create_fieldcat.
  wa_fieldcatalog_vbrk = VALUE #( col_pos = '1'
                             fieldname = 'VBELN'
                             scrtext_l = 'Doc Number').
  APPEND wa_fieldcatalog_vbrk TO it_fieldcatalog_vbrk.
  wa_fieldcatalog_vbrk = VALUE #( col_pos = '2'
                           fieldname = 'KNUMV'
                           scrtext_l = 'Condition Number').
  APPEND wa_fieldcatalog_vbrk TO it_fieldcatalog_vbrk.

    wa_fieldcatalog_condition = VALUE #( col_pos = '1'
                             fieldname = 'KNUMV'
                             scrtext_l = 'Condition Number').
  APPEND wa_fieldcatalog_condition TO it_fieldcatalog_condition.

  wa_fieldcatalog_condition = VALUE #( col_pos = '2'
                           fieldname = 'KBETR'
                           scrtext_l = 'Amount').
  APPEND wa_fieldcatalog_condition TO it_fieldcatalog_condition.
  wa_layout-cwidth_opt = 'X'.
ENDFORM.

FORM display.
  CREATE OBJECT lo_left_alv_grid
    EXPORTING
      i_parent          = lo_left_container " Parent Container
    EXCEPTIONS
      error_cntl_create = 1                       " Error when creating the control
      error_cntl_init   = 2                       " Error While Initializing Control
      error_cntl_link   = 3                       " Error While Linking Control
      error_dp_create   = 4                       " Error While Creating DataProvider Control
      OTHERS            = 5.
  CALL METHOD lo_left_alv_grid->set_table_for_first_display
    EXPORTING
      is_layout                     = wa_layout
    CHANGING
      it_outtab                     = it_vbrks
      it_fieldcatalog               = it_fieldcatalog_vbrk
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.


  CREATE OBJECT lo_right_alv_grid
    EXPORTING
      i_parent          = lo_right_container " Parent Container
    EXCEPTIONS
      error_cntl_create = 1                       " Error when creating the control
      error_cntl_init   = 2                       " Error While Initializing Control
      error_cntl_link   = 3                       " Error While Linking Control
      error_dp_create   = 4                       " Error While Creating DataProvider Control
      OTHERS            = 5.
  CALL METHOD lo_right_alv_grid->set_table_for_first_display
    EXPORTING
      is_layout                     = wa_layout
    CHANGING
      it_outtab                     = it_conditions
      it_fieldcatalog               = it_fieldcatalog_condition
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
ENDFORM.