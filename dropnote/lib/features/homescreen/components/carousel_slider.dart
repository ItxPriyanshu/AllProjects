import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyCarouselSlider extends ConsumerWidget {
  MyCarouselSlider({super.key});

  final carouselIndexProvider = StateProvider<int>((ref)=>0);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return CarouselSlider.builder(
      itemCount: 15,
      itemBuilder: (context, index, realIndex) {
        final currentIndex = ref.watch(carouselIndexProvider);
        return GestureDetector(
          onTap: () {}, //future work
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 5,
                  shape: CircleBorder(),
                  shadowColor: Colors.grey,
                  child: CircleAvatar(
                    
                    radius: 40,
                    // maxRadius: 70,
                    backgroundColor: (index==currentIndex)?Colors.white:Colors.grey,
                    child: (index == currentIndex)
                        ? Icon(Icons.menu, color: Colors.black)
                        : Icon(Icons.more_horiz, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      options: CarouselOptions(
        height: 110,
        // aspectRatio: 30/10,
        autoPlay: true,
        enlargeCenterPage: true,
        autoPlayInterval: const Duration(seconds: 3),
        viewportFraction: 0.25.r,
        onPageChanged: (index,reason){
          ref.read(carouselIndexProvider.notifier).state = index;
        }
      ),
    );
  }
}
