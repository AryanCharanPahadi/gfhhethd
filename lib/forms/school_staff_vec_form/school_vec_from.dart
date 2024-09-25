import 'dart:convert';
import 'dart:io';
import 'package:app17000ft_new/forms/school_staff_vec_form/school_vec_controller.dart';
import 'package:app17000ft_new/forms/school_staff_vec_form/school_vec_modals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:app17000ft_new/components/custom_appBar.dart';
import 'package:app17000ft_new/components/custom_button.dart';
import 'package:app17000ft_new/components/custom_imagepreview.dart';
import 'package:app17000ft_new/components/custom_textField.dart';
import 'package:app17000ft_new/components/error_text.dart';
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/forms/cab_meter_tracking_form/cab_meter_tracing_controller.dart';
import 'package:app17000ft_new/helper/responsive_helper.dart';
import 'package:app17000ft_new/tourDetails/tour_controller.dart';
import 'package:app17000ft_new/components/custom_dropdown.dart';
import 'package:app17000ft_new/components/custom_labeltext.dart';
import 'package:app17000ft_new/components/custom_sizedBox.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../base_client/base_client.dart';
import '../../components/custom_snackbar.dart';
import '../../helper/database_helper.dart';
import '../../home/home_screen.dart';

class SchoolStaffVecForm extends StatefulWidget {
  String? userid;
  String? office;
  final SchoolStaffVecRecords? existingRecord;
  SchoolStaffVecForm({
    super.key,
    this.userid,
    String? office,
    this.existingRecord,
  });
  @override
  State<SchoolStaffVecForm> createState() => _SchoolStaffVecFormState();
}

class _SchoolStaffVecFormState extends State<SchoolStaffVecForm> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> splitSchoolLists = [];
  String? _selectedDesignation;
  String? _selected2Designation;
  String? _selected3Designation;
  // Start of Showing Fields
  bool showBasicDetails = true; // For show Basic Details
  bool showStaffDetails = false; //For show and hide School Facilities
  bool showSmcVecDetails = false; //For show and hide Library
  // End of Showing Fields

  // Start of selecting Field
  String? _selectedValue = ''; // For the UDISE code
  String? _selectedValue2 = ''; // For the Gender
  String? _selectedValue3 = ''; // For the Gender2
  // End of selecting Field error

  // Start of radio Field
  bool _radioFieldError = false; // For the UDISE code
  bool _radioFieldError2 = false; // For the Gender
  bool _radioFieldError3 = false; // For the Gender2

  // End of radio Field error




  @override
  void initState() {
    super.initState();

    // Ensure the controller is registered
    if (!Get.isRegistered<SchoolStaffVecController>()) {
      Get.put(SchoolStaffVecController());
    }

    // Get the controller instance
    final schoolStaffVecController = Get.find<SchoolStaffVecController>();

    // Check if this is in edit mode (i.e., if an existing record is provided)
    if (widget.existingRecord != null) {
      final existingRecord = widget.existingRecord!;
      print("This is edit mode: ${existingRecord.tourId.toString()}");
      print(jsonEncode(existingRecord));

      // Populate the controllers with existing data
      schoolStaffVecController.correctUdiseCodeController.text =
          existingRecord.correctUdise ?? '';
      schoolStaffVecController.nameOfHoiController.text =
          existingRecord.headName ?? '';
      schoolStaffVecController.staffPhoneNumberController.text =
          existingRecord.headMobile ??
              ''; // Use mobileOfHoi for staffPhoneNumber
      schoolStaffVecController.emailController.text =
          existingRecord.headEmail ?? '';
      schoolStaffVecController.nameOfchairpersonController.text =
          existingRecord.SmcVecName ?? '';
      schoolStaffVecController.email2Controller.text =
          existingRecord.vecEmail ?? '';
      schoolStaffVecController.totalVecStaffController.text =
          existingRecord.vecTotal ?? '';
      schoolStaffVecController.chairPhoneNumberController.text =
          existingRecord.vecMobile ?? '';
      schoolStaffVecController.totalTeachingStaffController.text =
      (existingRecord.totalTeachingStaff ?? '');
      schoolStaffVecController.totalNonTeachingStaffController.text =
      (existingRecord.totalNonTeachingStaff ?? '');
      schoolStaffVecController.totalStaffController.text =
      (existingRecord.totalStaff ?? '');
      // Set other dropdown values
      _selectedValue = existingRecord.udiseValue;
      _selectedValue2 = existingRecord.headGender;
      _selectedValue3 = existingRecord.genderVec;
      _selectedDesignation = existingRecord.headDesignation;
      _selected2Designation = existingRecord.vecQualification;
      _selected3Designation = existingRecord.meetingDuration;

      // Set other fields related to tour and school
      schoolStaffVecController.setTour(existingRecord.tourId);
      schoolStaffVecController.setSchool(existingRecord.school ?? '');
    }
  }


  final SchoolStaffVecController schoolStaffVecController =
  Get.put(SchoolStaffVecController());

  void updateTotalStaff() {
    final totalTeachingStaff = int.tryParse(
        schoolStaffVecController.totalTeachingStaffController.text) ??
        0;
    final totalNonTeachingStaff = int.tryParse(
        schoolStaffVecController.totalNonTeachingStaffController.text) ??
        0;
    final totalStaff = totalTeachingStaff + totalNonTeachingStaff;

    schoolStaffVecController.totalStaffController.text = totalStaff.toString();
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsive = Responsive(context);
    return WillPopScope(
      onWillPop: () async {
        bool shouldPop =
        await BaseClient().showLeaveConfirmationDialog(context);
        return shouldPop;
      },
      child: Scaffold(
          appBar: const CustomAppbar(
            title: 'School Staff & SMC/VEC Details',
          ),
          body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(children: [
                    GetBuilder<SchoolStaffVecController>(
                        init: SchoolStaffVecController(),
                        builder: (schoolStaffVecController) {
                          return Form(
                              key: _formKey,
                              child: GetBuilder<TourController>(
                                  init: TourController(),
                                  builder: (tourController) {
                                    tourController.fetchTourDetails();
                                    return Column(children: [
                                      if (showBasicDetails) ...[
                                        LabelText(
                                          label: 'Basic Details',
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: 'Tour ID',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomDropdownFormField(
                                          focusNode: schoolStaffVecController
                                              .tourIdFocusNode,
                                          options: tourController
                                              .getLocalTourList
                                              .map((e) => e.tourId!)
                                              .toList(),
                                          selectedOption:
                                          schoolStaffVecController
                                              .tourValue,
                                          onChanged: (value) {
                                            splitSchoolLists = tourController
                                                .getLocalTourList
                                                .where((e) => e.tourId == value)
                                                .map((e) => e.allSchool!
                                                .split('|')
                                                .toList())
                                                .expand((x) => x)
                                                .toList();
                                            setState(() {
                                              schoolStaffVecController
                                                  .setSchool(null);
                                              schoolStaffVecController
                                                  .setTour(value);
                                            });
                                          },
                                          labelText: "Select Tour ID",
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: 'School',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        DropdownSearch<String>(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please Select School";
                                            }
                                            return null;
                                          },
                                          popupProps: PopupProps.menu(
                                            showSelectedItems: true,
                                            showSearchBox: true,
                                            disabledItemFn: (String s) =>
                                                s.startsWith('I'),
                                          ),
                                          items: splitSchoolLists,
                                          dropdownDecoratorProps:
                                          const DropDownDecoratorProps(
                                            dropdownSearchDecoration:
                                            InputDecoration(
                                              labelText: "Select School",
                                              hintText: "Select School ",
                                            ),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              schoolStaffVecController
                                                  .setSchool(value);
                                            });
                                          },
                                          selectedItem: schoolStaffVecController
                                              .schoolValue,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label:
                                          'Is this UDISE code is correct?',
                                          astrick: true,
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(right: 300),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue: _selectedValue,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedValue =
                                                    value as String?;
                                                  });
                                                },
                                              ),
                                              const Text('Yes'),
                                            ],
                                          ),
                                        ),
                                        CustomSizedBox(
                                          value: 150,
                                          side: 'width',
                                        ),
                                        // make it that user can also edit the tourId and school
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(right: 300),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue: _selectedValue,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedValue =
                                                    value as String?;
                                                  });
                                                },
                                              ),
                                              const Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (_radioFieldError)
                                          const Padding(
                                            padding:
                                            EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        if (_selectedValue == 'No') ...[
                                          LabelText(
                                            label:
                                            'Write Correct UDISE school code',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          CustomTextFormField(
                                            textController:
                                            schoolStaffVecController
                                                .correctUdiseCodeController,
                                            textInputType: TextInputType.number,
                                            labelText:
                                            'Enter correct UDISE code',
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please fill this field';
                                              }
                                              if (!RegExp(r'^[0-9]+$')
                                                  .hasMatch(value)) {
                                                return 'Please enter a valid number';
                                              }
                                              return null;
                                            },
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ],

                                        CustomButton(
                                          title: 'Next',
                                          onPressedButton: () {
                                            print('submit Basic Details');
                                            setState(() {
                                              _radioFieldError =
                                                  _selectedValue == null ||
                                                      _selectedValue!.isEmpty;
                                            });

                                            if (_formKey.currentState!
                                                .validate() &&
                                                !_radioFieldError) {
                                              setState(() {
                                                showBasicDetails = false;
                                                showStaffDetails = true;
                                              });
                                            }
                                          },
                                        ),

                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                      ],
                                      // End of Basic Details

                                      //start of staff Details
                                      if (showStaffDetails) ...[
                                        LabelText(
                                          label: 'Staff Details',
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: 'Name Of Head Of Institute',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        CustomTextFormField(
                                          textController:
                                          schoolStaffVecController
                                              .nameOfHoiController,
                                          labelText: 'Enter Name',
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Write Name';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        LabelText(
                                          label: 'Gender',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),

                                        // Wrapping in a LayoutBuilder to adjust based on available width
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value: 'Male',
                                                      groupValue:
                                                      _selectedValue2,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _selectedValue2 =
                                                          value as String?;
                                                          _radioFieldError2 =
                                                          false; // Reset error state
                                                        });
                                                      },
                                                    ),
                                                    const Text('Male'),
                                                  ],
                                                ),
                                                SizedBox(
                                                    width: screenWidth *
                                                        0.1), // Adjust spacing based on screen width
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value: 'Female',
                                                      groupValue:
                                                      _selectedValue2,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _selectedValue2 =
                                                          value as String?;
                                                          _radioFieldError2 =
                                                          false; // Reset error state
                                                        });
                                                      },
                                                    ),
                                                    const Text('Female'),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),

                                        if (_radioFieldError2)
                                          const Padding(
                                            padding:
                                            EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Please select an option',
                                              style:
                                              TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),

                                        LabelText(
                                          label: 'Mobile Number',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                          schoolStaffVecController
                                              .staffPhoneNumberController,
                                          labelText: 'Enter Mobile Number',
                                          textInputType: TextInputType.number,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                10),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please Enter Mobile';
                                            }

                                            // Regex for validating Indian phone number
                                            String pattern = r'^[6-9]\d{9}$';
                                            RegExp regex = RegExp(pattern);

                                            if (!regex.hasMatch(value)) {
                                              return 'Enter a valid Mobile number';
                                            }

                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: 'Email ID',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                          schoolStaffVecController
                                              .emailController,
                                          labelText: 'Enter Email',
                                          textInputType:
                                          TextInputType.emailAddress,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter Email';
                                            }

                                            // Regular expression for validating email
                                            final emailRegex = RegExp(
                                              r'^[^@]+@[^@]+\.[^@]+$',
                                              caseSensitive: false,
                                            );

                                            if (!emailRegex.hasMatch(value)) {
                                              return 'Please Enter a Valid Email Address';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: 'Designation',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'Select a designation',
                                            border: OutlineInputBorder(),
                                          ),
                                          value: _selectedDesignation,
                                          items: [
                                            DropdownMenuItem(
                                                value: 'head_master_head_mistress',
                                                child: Text('HeadMaster/HeadMistress')),
                                            DropdownMenuItem(
                                                value: 'principal',
                                                child: Text('Principal')),
                                            DropdownMenuItem(
                                                value: 'incharge',
                                                child: Text('Incharge')),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedDesignation = value;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Please select a designation';
                                            }
                                            return null;
                                          },
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        LabelText(
                                          label:
                                          'Total Teaching Staff (Including Head Of Institute)',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(value: 20, side: 'height'),
                                        CustomTextFormField(
                                          textController: schoolStaffVecController
                                              .totalTeachingStaffController,
                                          labelText: 'Enter Teaching Staff',
                                          textInputType: TextInputType.number,

                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please Enter Number';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                          onChanged: (value) =>
                                              updateTotalStaff(), // Update total staff when this field changes
                                        ),

                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        LabelText(
                                          label: 'Total Non Teaching Staff',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(value: 20, side: 'height'),
                                        CustomTextFormField(
                                          textController: schoolStaffVecController
                                              .totalNonTeachingStaffController,
                                          labelText: 'Enter Teaching Staff',
                                          textInputType: TextInputType.number,

                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please Enter Number';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                          onChanged: (value) =>
                                              updateTotalStaff(), // Update total staff when this field changes
                                        ),

                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        LabelText(
                                          label: 'Total Staff',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(value: 20, side: 'height'),
                                        CustomTextFormField(
                                          textController:
                                          schoolStaffVecController.totalStaffController,
                                          labelText: 'Enter Teaching Staff',

                                          showCharacterCount: true,
                                          readOnly: true, // Make this field read-only
                                        ),

                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        Row(
                                          children: [
                                            CustomButton(
                                                title: 'Back',
                                                onPressedButton: () {
                                                  setState(() {
                                                    showBasicDetails = true;
                                                    showStaffDetails = false;
                                                    false;
                                                  });
                                                }),
                                            const Spacer(),
                                            CustomButton(
                                              title: 'Next',
                                              onPressedButton: () {

                                                print('submit staff details');
                                                setState(() {
                                                  _radioFieldError2 =
                                                      _selectedValue2 == null ||
                                                          _selectedValue2!
                                                              .isEmpty;
                                                });

                                                if (_formKey.currentState!
                                                    .validate() &&
                                                    !_radioFieldError2) {
                                                  setState(() {
                                                    showStaffDetails = false;
                                                    showSmcVecDetails = true;
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        CustomSizedBox(
                                          value: 40,
                                          side: 'height',
                                        ),
                                      ], //end of staff details

                                      // start of staff vec details
                                      if (showSmcVecDetails) ...[
                                        LabelText(
                                          label: 'SMC VEC Details',
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: 'Name Of SMC/VEC chairperson',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        CustomTextFormField(
                                          textController:
                                          schoolStaffVecController
                                              .nameOfchairpersonController,
                                          labelText: 'Enter Name',
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Write Name';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        LabelText(
                                          label: 'Gender',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(value: 20, side: 'height'),

                                        // Wrapping in a LayoutBuilder to adjust based on available width
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value: 'Male',
                                                      groupValue: _selectedValue3,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _selectedValue3 = value as String?;
                                                          _radioFieldError3 = false; // Reset error state
                                                        });
                                                      },
                                                    ),
                                                    const Text('Male'),
                                                  ],
                                                ),
                                                SizedBox(width: screenWidth * 0.1), // Adjust spacing based on screen width
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value: 'Female',
                                                      groupValue: _selectedValue3,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _selectedValue3 = value as String?;
                                                          _radioFieldError3 = false; // Reset error state
                                                        });
                                                      },
                                                    ),
                                                    const Text('Female'),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),

                                        if (_radioFieldError3)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: const Text(
                                              'Please select an option',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        CustomSizedBox(value: 20, side: 'height'),

                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: 'Mobile Number',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                          schoolStaffVecController
                                              .chairPhoneNumberController,
                                          labelText: 'Enter Mobile Number',
                                          textInputType: TextInputType.number,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                10),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please Enter Mobile';
                                            }

                                            // Regex for validating Indian phone number
                                            String pattern = r'^[6-9]\d{9}$';
                                            RegExp regex = RegExp(pattern);

                                            if (!regex.hasMatch(value)) {
                                              return 'Enter a valid Mobile number';
                                            }

                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: 'Email ID',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                          schoolStaffVecController
                                              .email2Controller,
                                          labelText: 'Enter Email',
                                          textInputType:
                                          TextInputType.emailAddress,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter Email';
                                            }

                                            // Regular expression for validating email
                                            final emailRegex = RegExp(
                                              r'^[^@]+@[^@]+\.[^@]+$',
                                              caseSensitive: false,
                                            );

                                            if (!emailRegex.hasMatch(value)) {
                                              return 'Please Enter a Valid Email Address';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label:
                                          'Highest Education Qualification',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'Select qualification',
                                            border: OutlineInputBorder(),
                                          ),
                                          value: _selected2Designation,
                                          items: [
                                            DropdownMenuItem(
                                                value: 'non_graduate',
                                                child: Text('Non Graduate')),
                                            DropdownMenuItem(
                                                value: 'graduate',
                                                child: Text('Graduate')),
                                            DropdownMenuItem(
                                                value: 'post_graduate',
                                                child: Text('Post Graduate')),
                                            DropdownMenuItem(
                                                value: 'others_qualification',
                                                child: Text('Others')),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selected2Designation = value;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Please select a qualification';
                                            }
                                            return null;
                                          },
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        LabelText(
                                          label: 'Total SMC VEC Staff',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        CustomTextFormField(
                                          textController:
                                          schoolStaffVecController
                                              .totalVecStaffController,
                                          labelText:
                                          'Enter Total SMC VEC member',
                                          textInputType: TextInputType.number,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Write Number';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label:
                                          'How often does the school hold an SMC/VEC meeting',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'Select frequency',
                                            border: OutlineInputBorder(),
                                          ),
                                          value: _selected3Designation,
                                          items: [
                                            DropdownMenuItem(
                                                value: 'once_a_month',
                                                child: Text('Once a month')),
                                            DropdownMenuItem(
                                                value: 'once_a_quarter',
                                                child: Text('Once a quarter')),
                                            DropdownMenuItem(
                                                value: 'once_in_6_months',
                                                child: Text('Once in 6 months')),
                                            DropdownMenuItem(
                                                value: 'once_a_year',
                                                child: Text('Once a year')),
                                            DropdownMenuItem(
                                                value: 'others_frequency',
                                                child: Text('Others')),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selected3Designation = value;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Please select a frequency';
                                            }
                                            return null;
                                          },
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        Row(
                                          children: [
                                            CustomButton(
                                                title: 'Back',
                                                onPressedButton: () {
                                                  setState(() {
                                                    showStaffDetails = true;
                                                    showSmcVecDetails = false;
                                                  });
                                                }),
                                            const Spacer(),
                                            CustomButton(
                                                title: 'Submit',
                                                onPressedButton: () async {

                                                  setState(() {
                                                    _radioFieldError3 =
                                                        _selectedValue3 ==
                                                            null ||
                                                            _selectedValue3!
                                                                .isEmpty;
                                                  });
                                                  if (_formKey.currentState!
                                                      .validate() &&
                                                      !_radioFieldError3) {
                                                    print('Submit Vec Details');

                                                    DateTime now =
                                                    DateTime.now();
                                                    String formattedDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(now);
                                                    SchoolStaffVecRecords enrolmentCollectionObj = SchoolStaffVecRecords(
                                                        tourId: schoolStaffVecController.tourValue ??
                                                            '',
                                                        school: schoolStaffVecController.schoolValue ??
                                                            '',
                                                        udiseValue: _selectedValue!,
                                                        correctUdise: schoolStaffVecController
                                                            .correctUdiseCodeController
                                                            .text,
                                                        headName: schoolStaffVecController
                                                            .nameOfHoiController.text,
                                                        headMobile: schoolStaffVecController
                                                            .staffPhoneNumberController
                                                            .text,
                                                        headEmail: schoolStaffVecController
                                                            .emailController.text,
                                                        totalTeachingStaff:
                                                        schoolStaffVecController
                                                            .totalTeachingStaffController
                                                            .text,
                                                        totalNonTeachingStaff:
                                                        schoolStaffVecController
                                                            .totalNonTeachingStaffController
                                                            .text,
                                                        totalStaff: schoolStaffVecController
                                                            .totalStaffController.text,
                                                        vecMobile: schoolStaffVecController.chairPhoneNumberController.text,
                                                        vecEmail: schoolStaffVecController.email2Controller.text,
                                                        vecTotal: schoolStaffVecController.totalVecStaffController.text,
                                                        otherQual: schoolStaffVecController.QualSpecifyController.text,
                                                        other: schoolStaffVecController.QualSpecify2Controller.text,
                                                        SmcVecName: schoolStaffVecController.nameOfchairpersonController.text,
                                                        headGender: _selectedValue2!,
                                                        genderVec: _selectedValue3!,
                                                        headDesignation: _selectedDesignation!,
                                                        meetingDuration: _selected3Designation!,
                                                        vecQualification: _selected2Designation!,
                                                        createdAt: formattedDate.toString(),
                                                        createdBy: widget.userid.toString());



                                                    int result =
                                                    await LocalDbController()
                                                        .addData(
                                                        schoolStaffVecRecords:
                                                        enrolmentCollectionObj);
                                                    if (result > 0) {
                                                      schoolStaffVecController
                                                          .clearFields();
                                                      setState(() {
                                                        // Clear the image list
                                                        _selectedValue = '';
                                                        _selectedValue2 = '';
                                                        _selectedValue3 = '';
                                                      });

                                                      await saveDataToFile(enrolmentCollectionObj).then((_) {
                                                        // If successful, show a snackbar indicating the file was downloaded
                                                        customSnackbar(
                                                          'File downloaded successfully',
                                                          'downloaded',
                                                          AppColors.primary,
                                                          AppColors.onPrimary,
                                                          Icons.file_download_done,
                                                        );
                                                      }).catchError((error) {
                                                        // If there's an error during download, show an error snackbar
                                                        customSnackbar(
                                                          'Error',
                                                          'File download failed: $error',
                                                          AppColors.primary,
                                                          AppColors.onPrimary,
                                                          Icons.error,
                                                        );
                                                      });

                                                      customSnackbar(
                                                          'Submitted Successfully',
                                                          'Submitted',
                                                          AppColors.primary,
                                                          AppColors.onPrimary,
                                                          Icons.verified);

                                                      // Navigate to HomeScreen
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                            const HomeScreen()),
                                                      );
                                                    } else {
                                                      customSnackbar(
                                                          'Error',
                                                          'Something went wrong',
                                                          AppColors.error,
                                                          Colors.white,
                                                          Icons.error);
                                                    }
                                                  } else {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                        FocusNode());
                                                  }
                                                }),
                                          ],
                                        ),
                                      ] // End of staff vec details
                                    ]);
                                  }));
                        })
                  ])))),
    );
  }
}




Future<void> saveDataToFile(SchoolStaffVecRecords data) async {
  try {
    // Request storage permissions
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Use path_provider to get a valid directory, such as downloads
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          String newPath = '';
          List<String> folders = directory.path.split('/');
          for (int x = 1; x < folders.length; x++) {
            String folder = folders[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          directory = Directory("$newPath/Download");
        }
      }

      if (directory != null && !await directory.exists()) {
        await directory.create(
            recursive: true); // Create the directory if it doesn't exist
      }

      final path = '${directory!.path}/school_vec_form_${data
          .createdBy}.txt';

      // Convert the EnrolmentCollectionModel object to a JSON string
      String jsonString = jsonEncode(data);

      // Write the JSON string to a file
      File file = File(path);
      await file.writeAsString(jsonString);

      print('Data saved to $path');
    } else {
      print('Storage permission not granted');
      // Optionally, handle what happens if permission is denied
    }
  } catch (e) {
    print('Error saving data: $e');
  }
}