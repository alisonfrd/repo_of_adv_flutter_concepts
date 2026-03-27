import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_arch_reso/core/network/network_info.dart';
import 'network_info_test.mocks.dart';

@GenerateMocks([InternetConnectionChecker])
void main() {
  late NetWorkInfoImpl netWorkInfo;
  late MockInternetConnectionChecker mockInternetConnectionChecker;

  setUp(() {
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    netWorkInfo = NetWorkInfoImpl(mockInternetConnectionChecker);
  });

  group('isConnected', () {
    test(
      'should forward the call to InternetConnectionChecker hasConnection',
      () async {
        // arrange
        const tHasConnection = true;

        when(
          mockInternetConnectionChecker.hasConnection,
        ).thenAnswer((_) async => tHasConnection);

        // act
        // NOTICE: We`re NOT awaiting the result
        final result = netWorkInfo.isConnected;

        //assert
        verify(mockInternetConnectionChecker.hasConnection);
        expect(result, completion(tHasConnection));
      },
    );
  });
}
