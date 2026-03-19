import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:omnibook/features/presentation/data/sample_services.dart';
import 'package:omnibook/features/presentation/screens/service_selection_sheet.dart';
import 'package:omnibook/features/presentation/theme/app_colors.dart';
import 'package:omnibook/features/presentation/utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  static const List<_CategoryItem> _categories = <_CategoryItem>[
    _CategoryItem(label: 'Haircut', iconAsset: 'assets/home/haircut.svg'),
    _CategoryItem(label: 'Nails', iconAsset: 'assets/home/nails.svg'),
    _CategoryItem(label: 'Facial', iconAsset: 'assets/home/facial.svg'),
    _CategoryItem(label: 'Coloring', iconAsset: 'assets/home/colouring.svg'),
    _CategoryItem(label: 'Spa', iconAsset: 'assets/home/spa.svg'),
    _CategoryItem(label: 'Waxing', iconAsset: 'assets/home/waxing.svg'),
    _CategoryItem(label: 'Makeup', iconAsset: 'assets/home/makeup.svg'),
    _CategoryItem(label: 'Massage', iconAsset: 'assets/home/massage.svg'),
  ];

  Future<void> _openServiceSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ServiceSelectionSheet(),
    );
  }

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() {
        _navIndex = 0;
      });
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Coming soon: this feature is in progress.'),
        ),
      );
  }

  Widget _navIcon(String assetPath, bool active) {
    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        active ? AppColors.teal : const Color(0xFF99A1AE),
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.teal,
        onPressed: () => _openServiceSheet(context),
        icon: const Icon(Icons.event_available_rounded, color: Colors.white),
        label: const Text(
          'Book Now',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        selectedItemColor: AppColors.teal,
        unselectedItemColor: const Color(0xFF99A1AE),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _navIcon('assets/navBar/home.svg', _navIndex == 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/navBar/explore.svg', _navIndex == 1),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/navBar/calendar.svg', _navIndex == 2),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/navBar/alerts.svg', _navIndex == 3),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/navBar/profile.svg', _navIndex == 4),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Hello, Samantha',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Find the service you want, and treat yourself',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: AppColors.teal,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _PromoBanner(onTap: () => _openServiceSheet(context)),
              const SizedBox(height: 18),
              const Text(
                'Quick Book Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sampleServices.length,
                  separatorBuilder: (context, separatorIndex) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final service = sampleServices[index];
                    return InkWell(
                      onTap: () => _openServiceSheet(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 170,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              service.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              formatDuration(service.durationInMinutes),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              formatMoney(service.price),
                              style: const TextStyle(
                                color: AppColors.teal,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'What do you want to do?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final item = _categories[index];
                  return GestureDetector(
                    onTap: () => _openServiceSheet(context),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 62,
                          width: 62,
                          decoration: const BoxDecoration(
                            color: AppColors.lightTeal,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: SvgPicture.asset(
                              item.iconAsset,
                              colorFilter: const ColorFilter.mode(
                                AppColors.teal,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Most Search Interest',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const <Widget>[
                  _InterestChip(
                    label: 'Haircut',
                    iconAsset: 'assets/home/haircut.svg',
                  ),
                  _InterestChip(
                    label: 'Facial',
                    iconAsset: 'assets/home/facial.svg',
                  ),
                  _InterestChip(
                    label: 'Nails',
                    iconAsset: 'assets/home/nails.svg',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 120,
          child: SvgPicture.asset(
            'assets/home/discountCard.svg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightTeal,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.asset(
            iconAsset,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.teal,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.teal,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;
}
