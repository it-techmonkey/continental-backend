// lib/add_property_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'add_property_provider.dart';
import 'package:continental/services/places_service.dart';
import 'package:continental/services/s3_upload_service.dart';
import 'package:continental/services/developers_service.dart';
import 'package:continental/providers/language_provider.dart';
import 'package:continental/services/language_service.dart';
import 'package:continental/services/occupants_service.dart';
import '../../../../data/property_roi_data.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  final int? occupantRecordId; // Optional: if provided, we're in edit mode
  const AddPropertyScreen({super.key, this.occupantRecordId});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
   // Text Controllers
  final _propertyNameController = TextEditingController();
  final _rentController = TextEditingController();
  final _paymentCountController = TextEditingController();
  final _priceController = TextEditingController();
  final _handoverController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dldController = TextEditingController();
  final _quoodController = TextEditingController();
  final _otherChargesController = TextEditingController();
  final _penaltiesController = TextEditingController();

  // State for Images
  String? _propertyImageUrl;
  String? _agreementUrl;
  final S3UploadService _s3Service = S3UploadService();

  // State for Dropdowns
  String? _selectedPropertyType;
  String? _selectedMarket;
  String? _selectedRentFrequency;
  String? _selectedBedrooms;
  String? _selectedBathrooms;
  String? _selectedFurnishing;
  String? _selectedCity;
  String? _selectedLocation;
  String? _selectedLocality;
  double? _selectedLat;
  double? _selectedLng;
  String? _selectedViews;
  List<String> _selectedAmenities = []; // Changed to List for multi-select
  String? _selectedDeveloperName;
  List<String> _developerNames = [];

 // --- Dummy Data for Dropdowns ---
  final List<String> _propertyTypes = ['Apartment', 'Villa', 'Townhouse'];
  final List<String> _markets = ['Primary', 'Secondary'];
  final List<String> _rentFrequencies = ['Monthly', 'Quarterly', 'Yearly'];
  final List<String> _bedroomOptions = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  final List<String> _bathroomOptions = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  final List<String> _furnishingOptions = ['Furnished', 'Unfurnished', 'Partly Furnished'];
  final List<String> _cityOptions = ['Dubai', 'Abu Dhabi', 'Sharjah'];
  final List<String> _locationOptions = ['Downtown Dubai', 'Dubai Marina', 'Palm Jumeirah'];
  late final List<String> _localityOptions = PropertyROIData.getLocalities();
  final List<String> _viewOptions = ['Sea View', 'Burj Khalifa View', 'Community View'];
  final List<String> _amenityOptions = [
    'Pets_Allowed',
    'Swimming_Pool',
    'Gym',
    'Parking',
    'Security',
    'Balcony',
    'Garden',
    'Air_Conditioning',
    'Furnished',
    'Heating',
    'Jaccuzi',
    'Play_Area',
    'Lobby',
    'Scenic_View',
    'Wardrobes',
    'Spa',
    'Kitchen_Appliances',
    'Barbecue_Area',
    'Study',
    'Concierge_Service'
  ];



  bool _isLoadingProperty = false; // Flag to prevent clearing form during property load

  @override
  void initState() {
    super.initState();
    _loadDevelopers();
    if (widget.occupantRecordId != null) {
      _isLoadingProperty = true;
      _loadPropertyData();
    }
  }

  Future<void> _loadPropertyData() async {
    final occupantsService = OccupantsService();
    final property = await occupantsService.fetchOccupantDetail(widget.occupantRecordId!);

    if (property != null && mounted) {
      // Determine mode first
      final mode = property.propertyType.toLowerCase() == 'rental'
          ? PropertyMode.rental
          : PropertyMode.offPlan;
      
      // Set mode first (before setting other data) to prevent clearing
      // In edit mode, we set mode synchronously without triggering clear
      ref.read(propertyModeProvider.notifier).setMode(mode);
      
      // Wait a frame to ensure mode is set
      await Future.delayed(const Duration(milliseconds: 50));
      
      if (mounted) {
        setState(() {
          // Fill text controllers
          _propertyNameController.text = property.propertyName;
          _nameController.text = property.name;
          _emailController.text = property.email ?? '';
          _phoneController.text = property.phone;
          _dldController.text = property.dld?.toString() ?? '';
          _quoodController.text = property.quood?.toString() ?? '';
          _otherChargesController.text = property.otherCharges?.toString() ?? '';
          _penaltiesController.text = property.penalties?.toString() ?? '';

          // Set dropdowns - convert to string for dropdowns
          _selectedDeveloperName = property.developerName;
          _selectedPropertyType = property.homeType;
          _selectedMarket = property.market;
          _selectedBedrooms = property.bedrooms?.toString();
          _selectedBathrooms = property.bathrooms?.toString();
          // Map furnishing from backend enum to frontend display value
          _selectedFurnishing = _mapFurnishingFromBackend(property.furnishing);
          _selectedCity = property.city;
          _selectedLocation = property.location;
          _selectedLocality = property.locality;
          _selectedLat = property.latitude;
          _selectedLng = property.longitude;
          _selectedViews = property.propertyViews;
          _selectedAmenities = property.amenities ?? [];

          // Set images/URLs
          _propertyImageUrl = property.imageUrl;
          if (mode == PropertyMode.rental) {
            _rentController.text = property.rent?.toString() ?? '';
            // Map payment frequency from backend to frontend display value
            _selectedRentFrequency = _mapPaymentFrequencyFromBackend(property.paymentFrequency);
            _paymentCountController.text = property.paymentCount?.toString() ?? '';
            _agreementUrl = property.rentalAgreement;
          } else {
            _priceController.text = property.price?.toString() ?? '';
            _paymentCountController.text = property.paymentCount?.toString() ?? '';
            _agreementUrl = property.offplanAgreement;
            if (property.handover != null) {
              _handoverController.text = DateFormat('yyyy-MM-dd').format(property.handover!);
            } else if (property.completionDate != null) {
              _handoverController.text = property.completionDate!;
            }
          }
          
          // Mark loading as complete
          _isLoadingProperty = false;
        });
      }
    } else {
      _isLoadingProperty = false;
    }
  }

  // Map furnishing from backend enum to frontend display value
  String? _mapFurnishingFromBackend(String? f) {
    if (f == null) return null;
    final v = f.toLowerCase().trim();
    if (v == 'fully_furnished') return 'Furnished';
    if (v == 'partially_furnished') return 'Partly Furnished';
    if (v == 'unfurnished') return 'Unfurnished';
    if (v == 'kitchen_appliances_only') return 'Furnished'; // Map to closest match
    return f; // Return as-is if no match
  }

  // Map payment frequency from backend to frontend display value
  String? _mapPaymentFrequencyFromBackend(String? f) {
    if (f == null) return null;
    final v = f.toLowerCase().trim();
    if (v == 'monthly') return 'Monthly';
    if (v == 'quarterly') return 'Quarterly';
    if (v == 'yearly') return 'Yearly';
    return f; // Return as-is if no match
  }

  Future<void> _loadDevelopers() async {
    final developers = await DevelopersService.loadDevelopers();
    if (mounted) {
      setState(() {
        _developerNames = DevelopersService.getDeveloperNames(developers);
      });
    }
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _rentController.dispose();
    _paymentCountController.dispose();
    _priceController.dispose();
    _handoverController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dldController.dispose();
    _quoodController.dispose();
    _otherChargesController.dispose();
    _penaltiesController.dispose();
    super.dispose();
  }
  
 void _onSave() {
    if (_formKey.currentState!.validate()) {
      final mode = ref.read(propertyModeProvider);
      
      // Additional validation for dropdowns and required fields
      if (_selectedPropertyType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Property Type'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedMarket == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Market'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedBedrooms == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select No of Bedrooms'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedBathrooms == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select No of Bathrooms'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedFurnishing == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Furnishing'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select City'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedLocation == null || _selectedLat == null || _selectedLng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Location'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedLocality == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Locality'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedViews == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Views From Property'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedAmenities.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one Amenity'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_propertyImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload Property Image'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_agreementUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload Agreement'), backgroundColor: Colors.red),
        );
        return;
      }
      if (mode == PropertyMode.rental) {
        if (_selectedRentFrequency == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select Rent Frequency'), backgroundColor: Colors.red),
          );
          return;
        }
      }
      if (mode == PropertyMode.offPlan) {
        if (_handoverController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select Handover Date'), backgroundColor: Colors.red),
          );
          return;
        }
      }
      
      if (_selectedDeveloperName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Developer Name'), backgroundColor: Colors.red),
        );
        return;
      }

      final newProperty = NewProperty(
        mode: mode,
        propertyName: _propertyNameController.text,
        developerName: _selectedDeveloperName!,
        propertyType: _selectedPropertyType,
        market: _selectedMarket,
        noOfBedrooms: _selectedBedrooms,
        noOfBathrooms: _selectedBathrooms,
        furnishing: _selectedFurnishing,
        city: _selectedCity,
        location: _selectedLocation,
        locality: _selectedLocality,
        latitude: _selectedLat,
        longitude: _selectedLng,
        viewsFromProperty: _selectedViews,
        amenities: _selectedAmenities,
        rent: mode == PropertyMode.rental ? _rentController.text : null,
        rentFrequency: mode == PropertyMode.rental ? _selectedRentFrequency : null,
        paymentCount: _paymentCountController.text,
        price: _priceController.text.isNotEmpty ? _priceController.text : null,
        handover: mode == PropertyMode.offPlan && _handoverController.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd').parse(_handoverController.text)
            : null,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        dld: _dldController.text.isNotEmpty ? _dldController.text : null,
        quood: _quoodController.text.isNotEmpty ? _quoodController.text : null,
        otherCharges: _otherChargesController.text.isNotEmpty ? _otherChargesController.text : null,
        penalties: _penaltiesController.text.isNotEmpty ? _penaltiesController.text : null,
        propertyImageUrl: _propertyImageUrl,
        agreementUrl: _agreementUrl,
      );

      // Dismiss keyboard when form is submitted
      FocusScope.of(context).unfocus();

      // Check if we're in edit mode or add mode
      final isEditMode = widget.occupantRecordId != null;

      if (isEditMode) {
        ref.read(addPropertyProvider.notifier).update(widget.occupantRecordId!, newProperty).then((_) {
          final state = ref.read(addPropertyProvider);
          if (mounted && state is! AsyncError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Property Updated!'), backgroundColor: Colors.green),
            );
            context.pop();
          }
        });
      } else {
        ref.read(addPropertyProvider.notifier).save(newProperty).then((_) {
          final state = ref.read(addPropertyProvider);
          if (mounted && state is! AsyncError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Property Saved!'), backgroundColor: Colors.green),
            );
            context.pop();
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form.'), backgroundColor: Colors.red),
      );
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset(); // Resets validation state
    _propertyNameController.clear();
    _rentController.clear();
    _priceController.clear();
    _handoverController.clear();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _dldController.clear();
    _quoodController.clear();
    _otherChargesController.clear();
    _penaltiesController.clear();
    
    // Reset all dropdowns
    setState(() {
      _selectedPropertyType = null;
      _selectedMarket = null;
      _selectedRentFrequency = null;
      _selectedBedrooms = null;
      _selectedBathrooms = null;
      _selectedFurnishing = null;
      _selectedCity = null;
      _selectedLocation = null;
      _selectedLocality = null;
      _selectedViews = null;
      _selectedAmenities = [];
      _selectedDeveloperName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only clear form when mode changes in ADD mode (not EDIT mode)
    ref.listen<PropertyMode>(propertyModeProvider, (previous, next) {
      // Don't clear form if we're loading property data or in edit mode
      if (previous != next && !_isLoadingProperty && widget.occupantRecordId == null) {
        _clearForm();
      }
    });


    final selectedMode = ref.watch(propertyModeProvider);
    final addPropertyState = ref.watch(addPropertyProvider);
    final languageCode = ref.watch(languageProvider);
    String t(String key) => LanguageService.translate(key, languageCode);

    final isEditMode = widget.occupantRecordId != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: Text(isEditMode ? t('Edit Property') : t('Add'), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Padding for save button
              children: [
                _buildModeSelector(selectedMode, t, isEditMode),
                const SizedBox(height: 24),
                
               _buildSectionHeader(t('Property Details')),
                _CustomTextField(controller: _propertyNameController, label: t('Property Name'), translate: t),
                _SearchableDropdownField(
                  label: t('Developer Name'),
                  value: _selectedDeveloperName,
                  items: _developerNames,
                  onChanged: (v) => setState(() => _selectedDeveloperName = v),
                  translate: t,
                ),
                _CustomDropdownField(label: t('Property Type'), value: _selectedPropertyType, items: _propertyTypes, onChanged: (v) => setState(() => _selectedPropertyType = v), translate: t),
                _CustomDropdownField(label: t('Market'), value: _selectedMarket, items: _markets, onChanged: (v) => setState(() => _selectedMarket = v), translate: t),

                // --- Dynamic Fields based on Mode ---
                if (selectedMode == PropertyMode.rental) ..._buildRentalFields(t),
                if (selectedMode == PropertyMode.offPlan) ..._buildOffPlanFields(t),

                 _CustomDropdownField(label: t('No of Bedrooms'), value: _selectedBedrooms, items: _bedroomOptions, onChanged: (v) => setState(() => _selectedBedrooms = v), translate: t),
                _CustomDropdownField(label: t('No of Bathrooms'), value: _selectedBathrooms, items: _bathroomOptions, onChanged: (v) => setState(() => _selectedBathrooms = v), translate: t),
                _CustomDropdownField(label: t('Furnishing'), value: _selectedFurnishing, items: _furnishingOptions, onChanged: (v) => setState(() => _selectedFurnishing = v), translate: t),
                _CustomDropdownField(label: t('City'), value: _selectedCity, items: _cityOptions, onChanged: (v) => setState(() => _selectedCity = v), translate: t),
                _LocationSearchField(
                  initialText: _selectedLocation,
                  onSelected: (name, lat, lng){
                    setState((){
                      _selectedLocation = name;
                      _selectedLat = lat;
                      _selectedLng = lng;
                    });
                  },
                  translate: t,
                ),
                _CustomDropdownField(label: t('Locality'), value: _selectedLocality, items: _localityOptions, onChanged: (v) => setState(() => _selectedLocality = v), translate: t),
                _CustomDropdownField(label: t('Views From Property'), value: _selectedViews, items: _viewOptions, onChanged: (v) => setState(() => _selectedViews = v), translate: t),
                _MultiSelectDropdownField(
                  label: t('Amenities'),
                  selectedItems: _selectedAmenities,
                  items: _amenityOptions,
                  onChanged: (v) => setState(() => _selectedAmenities = v),
                ),
                
                const SizedBox(height: 24),
                _buildSectionHeader(t('Property Images')),
                _buildPropertyImageUpload(),
                const SizedBox(height: 16),
                _buildAgreementUpload(selectedMode == PropertyMode.rental ? 'Rental Agreement' : 'Off-Plan Agreement'),
                
                const SizedBox(height: 24),
                _buildSectionHeader(selectedMode == PropertyMode.rental ? t('Tenant Details') : t('Owner Details')),
                _CustomTextField(controller: _nameController, label: t('Name'), translate: t),
                _CustomTextField(controller: _emailController, label: t('Email Id'), validator: (v) => _validateEmail(v, t), translate: t),
                _CustomTextField(controller: _phoneController, label: t('Phone No'), isPhone: true, translate: t),
                
                const SizedBox(height: 24),
                _buildSectionHeader(t('Charges')),
                _CustomTextField(controller: _dldController, label: t('DLD'), numbersOnly: true, translate: t),
                _CustomTextField(controller: _quoodController, label: t('QUOOD'), numbersOnly: true, translate: t),
                _CustomTextField(controller: _otherChargesController, label: t('Other Charges'), numbersOnly: true, translate: t),
                _CustomTextField(controller: _penaltiesController, label: t('Penalties'), numbersOnly: true, translate: t),
              ],
            ),
          ),
          _buildSaveButton(addPropertyState.isLoading),
        ],
      ),
    );
  }

  List<Widget> _buildRentalFields(String Function(String) t) {
    return [
      _CustomTextField(controller: _priceController, label: t('Price'), keyboardType: TextInputType.number, translate: t),
      _CustomTextField(controller: _rentController, label: t('Rent'), keyboardType: TextInputType.number, translate: t),
      _CustomDropdownField(label: t('Rent Frequency'), value: _selectedRentFrequency, items: _rentFrequencies, onChanged: (v) => setState(() => _selectedRentFrequency = v), translate: t),
      _CustomTextField(controller: _paymentCountController, label: t('Payment Count'), keyboardType: TextInputType.number, translate: t),
    ];
  }

  List<Widget> _buildOffPlanFields(String Function(String) t) {
    return [
      _CustomTextField(controller: _priceController, label: t('Price'), keyboardType: TextInputType.number, translate: t),
      _CustomDatePickerField(controller: _handoverController, label: t('Handover'), translate: t),
      _CustomTextField(controller: _paymentCountController, label: t('Payment Count'), keyboardType: TextInputType.number, translate: t),
    ];
  }
  
  String? _validateEmail(String? value, String Function(String) t) {
    if (value == null || value.isEmpty) return t('Email cannot be empty');
    final emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) return t('Please enter a valid email');
    return null;
  }

  Widget _buildModeSelector(PropertyMode selectedMode, String Function(String) t, bool isEditMode) {
    // In edit mode, disable the mode selector (property type cannot be changed)
    if (isEditMode) {
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selectedMode == PropertyMode.rental ? Colors.yellow[700] : Colors.grey[800],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                selectedMode == PropertyMode.rental ? t('Rental') : t('Off Plan'),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: selectedMode == PropertyMode.rental ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    return Row(
      children: [
        _ModeChip(
          label: t('Rental'),
          isSelected: selectedMode == PropertyMode.rental,
          onTap: () => ref.read(propertyModeProvider.notifier).setMode(PropertyMode.rental),
        ),
        const SizedBox(width: 12),
        _ModeChip(
          label: t('Off Plan'),
          isSelected: selectedMode == PropertyMode.offPlan,
          onTap: () => ref.read(propertyModeProvider.notifier).setMode(PropertyMode.offPlan),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPropertyImageUpload() {
    return _ImageUploadField(
      label: 'Property Image',
      imageUrl: _propertyImageUrl,
      onTap: () async {
        final image = await _s3Service.pickImage();
        if (image != null) {
          // Show loading
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading image...'), duration: Duration(seconds: 1)),
          );
          final url = await _s3Service.uploadImage(
            imageFile: File(image.path),
            uploadType: 'property-image',
            fileName: image.name,
          );
          if (mounted) {
            setState(() => _propertyImageUrl = url);
            if (url != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image uploaded!'), backgroundColor: Colors.green),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload failed'), backgroundColor: Colors.red),
              );
            }
          }
        }
      },
    );
  }

  Widget _buildAgreementUpload(String label) {
    return _AgreementUploadField(
      label: label,
      fileUrl: _agreementUrl,
      onTap: () async {
        final result = await _s3Service.pickFile(
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          allowMultiple: false,
        );
        if (result != null && result.files.single.path != null) {
          // Show loading
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading file...'), duration: Duration(seconds: 1)),
          );
          final url = await _s3Service.uploadFile(
            file: File(result.files.single.path!),
            uploadType: 'agreement',
            fileName: result.files.single.name,
          );
          if (mounted) {
            setState(() => _agreementUrl = url);
            if (url != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File uploaded!'), backgroundColor: Colors.green),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload failed'), backgroundColor: Colors.red),
              );
            }
          }
        }
      },
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[700],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: isLoading
              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.black))
              : Text('Save', style: GoogleFonts.inter(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// --- Reusable Custom Widgets ---

class _ModeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ModeChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.yellow[700] : Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool isPhone;
  final String? Function(String?)? validator;
  final bool numbersOnly;
  final String Function(String)? translate;

  const _CustomTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.isPhone = false,
    this.validator,
    this.numbersOnly = false,
    this.translate,
  });

  @override
  Widget build(BuildContext context) {
    final t = translate ?? (String key) => key;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey[400])),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: numbersOnly ? TextInputType.number : keyboardType,
            inputFormatters: numbersOnly ? [
              FilteringTextInputFormatter.digitsOnly,
            ] : null,
            style: const TextStyle(color: Colors.white),
            validator: validator ?? (value) => (value == null || value.isEmpty) ? '${label} ${t('cannot be empty')}' : null,
            decoration: InputDecoration(
              hintText: t('Enter'),
              hintStyle: TextStyle(color: Colors.grey[700]),
              prefixIcon: isPhone ? const Padding(padding: EdgeInsets.only(left: 12.0, top: 12.0), child: Text('+971 | ', style: TextStyle(color: Colors.white, fontSize: 16))) : null,
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[800]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[800]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.yellow)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  // UPDATED: Add a hint parameter
  final String hint;
  final String Function(String)? translate;

  const _CustomDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    // UPDATED: Make the hint optional with a default value
    this.hint = 'Select',
    this.translate,
  });

  @override
  Widget build(BuildContext context) {
    final t = translate ?? (String key) => key;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey[400])),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            hint: Text(t(hint), style: TextStyle(color: Colors.grey[700]), overflow: TextOverflow.ellipsis),
            value: value,
            items: items.map((String item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(color: Colors.white),
              ),
            )).toList(),
            onChanged: onChanged,
            validator: (value) => (value == null) ? t('Please make a selection') : null,
            style: const TextStyle(color: Colors.white),
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[800]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[800]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.yellow)),
            ),
            dropdownColor: Colors.grey[900],
          ),
        ],
      ),
    );
  }
}

class _SearchableDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final String Function(String)? translate;

  const _SearchableDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.translate,
  });

  void _showSearchDialog(BuildContext context) {
    final t = translate ?? (String key) => key;
    final searchController = TextEditingController();
    List<String> filteredItems = List.from(items);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title with close icon
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            label,
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey, size: 24),
                          onPressed: () => Navigator.pop(dialogContext),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                  // Content
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: searchController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: t('Search') + '...',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[800],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[700]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[700]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.yellow),
                              ),
                            ),
                            onChanged: (query) {
                              setDialogState(() {
                                if (query.isEmpty) {
                                  filteredItems = List.from(items);
                                } else {
                                  filteredItems = items
                                      .where((item) => item.toLowerCase().contains(query.toLowerCase()))
                                      .toList();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Flexible(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 400),
                              child: filteredItems.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        t('No results found'),
                                        style: GoogleFonts.inter(color: Colors.grey[500]),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: filteredItems.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredItems[index];
                                        return ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          title: Text(
                                            item,
                                            style: GoogleFonts.inter(
                                              color: value == item ? Colors.yellow : Colors.white,
                                              fontWeight: value == item ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          trailing: value == item
                                              ? const Icon(Icons.check, color: Colors.yellow, size: 20)
                                              : null,
                                          onTap: () {
                                            onChanged(item);
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = translate ?? (String key) => key;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey[400])),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showSearchDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value ?? t('Select'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: value != null ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          if (value == null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                t('Please make a selection'),
                style: GoogleFonts.inter(color: Colors.red[400], fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomDatePickerField extends StatelessWidget {
    final TextEditingController controller;
    final String label;
    final String Function(String)? translate;

    const _CustomDatePickerField({required this.controller, required this.label, this.translate});

    Future<void> _selectDate(BuildContext context) async {
        final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
        );
        if (picked != null) {
            controller.text = "${picked.toLocal()}".split(' ')[0]; // Format as YYYY-MM-DD
        }
    }
    
    @override
    Widget build(BuildContext context) {
        final t = translate ?? (String key) => key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(label, style: GoogleFonts.inter(color: Colors.grey[400])),
                  const SizedBox(height: 8),
                  TextFormField(
                      controller: controller,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => (value == null || value.isEmpty) ? '${label} ${t('cannot be empty')}' : null,
                      decoration: InputDecoration(
                          hintText: t('Hand Over'),
                          hintStyle: TextStyle(color: Colors.grey[700]),
                          suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[800]!)),
                      ),
                  ),
              ],
          ),
      );
    }
}

// Location search field using Google Places Autocomplete
class _LocationSearchField extends StatefulWidget {
  final String? initialText;
  final void Function(String name, double lat, double lng) onSelected;
  final String Function(String)? translate;
  const _LocationSearchField({required this.initialText, required this.onSelected, this.translate});

  @override
  State<_LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<_LocationSearchField> {
  final _controller = TextEditingController();
  final _places = PlacesService();
  List<PlaceSuggestion> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) _controller.text = widget.initialText!;
  }

  @override
  void didUpdateWidget(_LocationSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if initialText changes
    if (widget.initialText != oldWidget.initialText && widget.initialText != null) {
      _controller.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    setState(() => _isLoading = true);
    final s = await _places.autocomplete(q);
    setState(() { _suggestions = s; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.translate ?? (String key) => key;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('Location'), style: GoogleFonts.inter(color: Colors.grey[400])),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '${t('Search for Properties')}...',
              hintStyle: TextStyle(color: Colors.grey[700]),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[800]!)),
              suffixIcon: _isLoading ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width:16, height:16, child: CircularProgressIndicator(strokeWidth: 2))) : const Icon(Icons.search, color: Colors.grey),
            ),
            onChanged: (v){ if (v.length > 2) _search(v); },
            validator: (v) => (v == null || v.isEmpty) ? '${t('Location')} ${t('cannot be empty')}' : null,
          ),
          if (_suggestions.isNotEmpty)
            Container(
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[800]!)),
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index){
                  final s = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(s.description, style: const TextStyle(color: Colors.white)),
                    onTap: () async {
                      final d = await _places.details(s.placeId);
                      if (d != null){
                        setState(() { _controller.text = d.name; _suggestions = []; });
                        widget.onSelected(d.name, d.lat, d.lng);
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Image Upload Field Widget
class _ImageUploadField extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final VoidCallback onTap;

  const _ImageUploadField({required this.label, this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey[400])),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: imageUrl == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, color: Colors.grey[400], size: 40),
                        const SizedBox(height: 8),
                        Text('Tap to upload image', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14)),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stack) => const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              const SizedBox(width: 4),
                              Text('Image uploaded', style: GoogleFonts.inter(color: Colors.green, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Agreement Upload Field Widget (for PDFs and images)
class _AgreementUploadField extends StatelessWidget {
  final String label;
  final String? fileUrl;
  final VoidCallback onTap;

  const _AgreementUploadField({required this.label, this.fileUrl, required this.onTap});

  bool _isImage(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.jpg') || 
           lowerUrl.endsWith('.jpeg') || 
           lowerUrl.endsWith('.png') || 
           lowerUrl.endsWith('.gif') ||
           lowerUrl.endsWith('.webp');
  }

  bool _isPdf(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  String _getFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last;
      }
      return 'File';
    } catch (e) {
      return 'File';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImage = fileUrl != null && _isImage(fileUrl!);
    final isPdf = fileUrl != null && _isPdf(fileUrl!);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey[400])),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: fileUrl == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, color: Colors.grey[400], size: 40),
                        const SizedBox(height: 8),
                        Text('Upload PDF, PNG or JPEG', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14)),
                        Text('Files Upto 20 MB', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12)),
                      ],
                    )
                  : isImage
                      ? Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(
                                  fileUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stack) => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, color: Colors.red, size: 40),
                                      const SizedBox(height: 8),
                                      Text('Failed to load image', style: GoogleFonts.inter(color: Colors.red, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                                  const SizedBox(width: 4),
                                  Text('Image uploaded', style: GoogleFonts.inter(color: Colors.green, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/images/pdf.svg', height: 50, colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _getFileName(fileUrl!),
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text('File uploaded', style: GoogleFonts.inter(color: Colors.green, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// Multi-Select Dropdown Field Widget
class _MultiSelectDropdownField extends StatefulWidget {
  final String label;
  final List<String> selectedItems;
  final List<String> items;
  final void Function(List<String>) onChanged;

  const _MultiSelectDropdownField({
    required this.label,
    required this.selectedItems,
    required this.items,
    required this.onChanged,
  });

  @override
  State<_MultiSelectDropdownField> createState() => _MultiSelectDropdownFieldState();
}

class _MultiSelectDropdownFieldState extends State<_MultiSelectDropdownField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: GoogleFonts.inter(color: Colors.grey[400])),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => _MultiSelectDialog(
                  items: widget.items,
                  selectedItems: widget.selectedItems,
                  onConfirm: (selected) {
                    widget.onChanged(selected);
                  },
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: widget.selectedItems.isEmpty
                        ? Text('Select amenities', style: TextStyle(color: Colors.grey[700]))
                        : Text(
                            widget.selectedItems.length == 1
                                ? widget.selectedItems.first
                                : '${widget.selectedItems.length} selected',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
          if (widget.selectedItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedItems.map((item) {
                return Chip(
                  label: Text(item.replaceAll('_', ' '), style: GoogleFonts.inter(fontSize: 12)),
                  backgroundColor: Colors.yellow[700],
                  deleteIcon: Icon(Icons.close, size: 18, color: Colors.black),
                  onDeleted: () {
                    final updated = List<String>.from(widget.selectedItems)..remove(item);
                    widget.onChanged(updated);
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final void Function(List<String>) onConfirm;

  const _MultiSelectDialog({
    required this.items,
    required this.selectedItems,
    required this.onConfirm,
  });

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List<String>.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text('Select Amenities', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 400),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final isSelected = _selectedItems.contains(item);
            return CheckboxListTile(
              title: Text(item.replaceAll('_', ' '), style: GoogleFonts.inter(color: Colors.white)),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedItems.add(item);
                  } else {
                    _selectedItems.remove(item);
                  }
                });
              },
              activeColor: Colors.yellow[700],
              checkColor: Colors.black,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_selectedItems);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
          child: Text('Confirm', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

