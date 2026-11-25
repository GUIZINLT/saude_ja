import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

import '../../../core/constants/specialty_icons.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/doctor.dart';
import '../../../data/models/specialty.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends StatefulWidget {
  /// Toque no card da próxima consulta (abre a aba Consultas).
  final VoidCallback? onOpenAppointments;

  const HomeView({super.key, this.onOpenAppointments});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // O controller fica na View porque é um objeto de interface; o texto
  // em si vai para o ViewModel a cada mudança.
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectSpecialty(HomeViewModel vm, Specialty specialty) {
    _searchController.text = specialty.name;
    unawaited(vm.selectSpecialty(specialty));
  }

  /// Abre os detalhes do médico; se uma consulta for marcada a partir
  /// dali, atualiza a Home.
  Future<void> _openDoctor(HomeViewModel vm, Doctor doctor) async {
    final scheduled = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.doctor, arguments: doctor.id);
    if (scheduled == true) unawaited(vm.load());
  }

  void _clearSearch(HomeViewModel vm) {
    _searchController.clear();
    vm.clearSearch();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Olá, ${vm.firstName}', style: context.typography.heading),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Como podemos ajudar hoje?',
                  style: context.typography.subtitle,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  hint: 'Buscar médico ou especialidade',
                  prefixIcon: Icons.search,
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: vm.setQuery,
                  suffixIcon: vm.isSearching
                      ? IconButton(
                          tooltip: 'Limpar busca',
                          icon: const Icon(Icons.close),
                          onPressed: () => _clearSearch(vm),
                        )
                      : null,
                ),
                if (vm.isSearching)
                  _SearchResults(vm: vm, onDoctorTap: (d) => _openDoctor(vm, d))
                else
                  ..._buildSections(vm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSections(HomeViewModel vm) {
    switch (vm.status) {
      case HomeStatus.loading:
        // Mesmo formato das seções, para a tela não "pular" ao carregar.
        return const [
          _SectionTitle('Especialidades'),
          Row(
            children: [
              Expanded(child: AppSkeleton(height: 112, radius: AppRadius.lg)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: AppSkeleton(height: 112, radius: AppRadius.lg)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: AppSkeleton(height: 112, radius: AppRadius.lg)),
            ],
          ),
          _SectionTitle('Próxima consulta'),
          SkeletonCard(showAvatar: false, lines: 4),
          _SectionTitle('Médicos em destaque'),
          SkeletonCard(),
          SizedBox(height: AppSpacing.sm),
          SkeletonCard(),
        ];
      case HomeStatus.error:
        return [
          const SizedBox(height: AppSpacing.xl),
          _ErrorState(message: vm.errorMessage!, onRetry: vm.load),
        ];
      case HomeStatus.ready:
        return [
          const _SectionTitle('Especialidades'),
          // Rolagem horizontal; a altura acompanha o conteúdo dos cards e
          // todos ficam com a altura do maior.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, s) in vm.specialties.indexed) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.sm),
                    SpecialtyCard(
                      title: s.name,
                      icon: SpecialtyIcons.of(s.icon),
                      onTap: () => _selectSpecialty(vm, s),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const _SectionTitle('Próxima consulta'),
          _NextAppointment(
            appointment: vm.nextAppointment,
            onTap: widget.onOpenAppointments,
          ),
          const _SectionTitle('Médicos em destaque'),
          _DoctorList(
            doctors: vm.featuredDoctors,
            onTap: (d) => _openDoctor(vm, d),
          ),
        ];
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg - 4,
        bottom: AppSpacing.sm,
      ),
      child: Text(text, style: context.typography.title),
    );
  }
}

class _NextAppointment extends StatelessWidget {
  final Appointment? appointment;
  final VoidCallback? onTap;

  const _NextAppointment({required this.appointment, this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    if (a == null) {
      return AppCard(
        child: Row(
          children: [
            Icon(
              Icons.event_available_outlined,
              color: context.colors.secondary,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Você não tem consultas agendadas.',
                style: context.typography.body,
              ),
            ),
          ],
        ),
      );
    }
    return AppointmentCard(
      doctorName: a.doctorName,
      specialty: a.specialtyName,
      date: DateFormatter.shortDate(a.startsAt),
      time: 'Às ${a.time}',
      status: a.status.label,
      onTap: onTap,
    );
  }
}

class _DoctorList extends StatelessWidget {
  final List<Doctor> doctors;
  final ValueChanged<Doctor> onTap;

  const _DoctorList({required this.doctors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final d in doctors) ...[
          DoctorCard(
            name: d.name,
            specialty: d.specialtyName,
            rating: d.rating,
            onTap: () => onTap(d),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final HomeViewModel vm;
  final ValueChanged<Doctor> onDoctorTap;

  const _SearchResults({required this.vm, required this.onDoctorTap});

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (vm.isSearchLoading) {
      content = const Column(
        children: [
          SkeletonCard(),
          SizedBox(height: AppSpacing.sm),
          SkeletonCard(),
        ],
      );
    } else if (vm.searchError != null) {
      content = Text(vm.searchError!, style: context.typography.body);
    } else if (vm.searchResults.isEmpty) {
      content = Text(
        'Nenhum médico encontrado para "${vm.query.trim()}".',
        style: context.typography.subtitle,
      );
    } else {
      content = _DoctorList(doctors: vm.searchResults, onTap: onDoctorTap);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          vm.isSearchLoading || vm.searchResults.isEmpty
              ? 'Resultados'
              : 'Resultados (${vm.searchResults.length})',
        ),
        content,
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.cloud_off_outlined, size: 48, color: context.colors.error),
        const SizedBox(height: AppSpacing.md),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.typography.body,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(label: 'Tentar novamente', onPressed: onRetry),
      ],
    );
  }
}
