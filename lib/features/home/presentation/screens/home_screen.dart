import 'package:flutter/material.dart';

import '../widgets/category_filter.dart';
import '../widgets/header.dart';
import '../widgets/muscle_group_grid.dart';
import '../widgets/recommended_workouts.dart';
import '../widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: Header(userName: 'Lina')),
            // SliverToBoxAdapter(child: CategoryFilter()),
            SliverToBoxAdapter(child: SectionTitle(title: 'Recommended Workouts')),
            SliverToBoxAdapter(child: RecommendedWorkouts()),
            SliverToBoxAdapter(child: SectionTitle(title: 'Explore by Muscle')),
            MuscleGrid(),
            SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}