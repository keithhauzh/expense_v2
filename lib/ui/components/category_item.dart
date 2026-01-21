import 'package:expense_v2/data/model/category.dart';
import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.category,
    required this.onClickItem,
  });
  final Category category;
  final Function(Category) onClickItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClickItem(category),
      child: Card(
        margin: const EdgeInsets.all(10.0),
        child: Container(
          margin: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [Text(category.name)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

