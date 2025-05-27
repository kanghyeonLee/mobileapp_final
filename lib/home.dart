// // Copyright 2018-present the Flutter authors. All Rights Reserved.
// //
// // Licensed under the Apache License, Version 2.0 (the "License");
// // you may not use this file except in compliance with the License.
// // You may obtain a copy of the License at
// //
// // http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing, software
// // distributed under the License is distributed on an "AS IS" BASIS,
// // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// // See the License for the specific language governing permissions and
// // limitations under the License.

// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             semanticLabel: 'prior',
//           ),
//           onPressed: () {
//             Navigator.pushReplacementNamed(context, '/login');
//           },
//         ),
//         title: const Text(
//             'Sync Your Snap'
//           ),
//         actions: <Widget>[
//           IconButton(
//               onPressed: (){

//               },
//               icon: const Icon(
//                 Icons.person
//               )
//             )
//         ],
//       ),
//       body: Center(
//         child: Column(
//           children: <Widget>[
//               TextButton(onPressed: (){
//                 Navigator.pushReplacementNamed(context, '/image');
//               },
//               child: Text('Go to image.dart'),
//             )
//           ],
//         )
//         ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, semanticLabel: 'prior'),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        title: const Text('Sync Your Snap'),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
        ],
      ),
      body: Stack(
        children: [
          // 스크롤 가능한 리스트
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 80.0),
            itemCount: 20,
            itemBuilder:
                (context, index) => ListTile(
                  leading: const Icon(Icons.image),
                  title: Text('더미 아이템 ${index + 1}'),
                  subtitle: const Text('설명 텍스트'),
                ),
          ),

          // 고정 버튼
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/image');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 12, 63, 151),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Go to image.dart'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
