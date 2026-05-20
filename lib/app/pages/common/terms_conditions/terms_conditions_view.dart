import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../i18n/strings.g.dart';
import '../../../data/repository/repository.dart';
import '../../../widgets/widgets.dart';

@RoutePage()
class TermsConditionsView extends ConsumerWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _termsConditionAsync = ref.watch(_termsConditionProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.pages.termAndCondition.title),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => ref.refresh(_termsConditionProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: _termsConditionAsync.when(
            skipLoadingOnRefresh: false,
            data: (data) {
              return HtmlWidget(
                '''
                    <div class="container">
                      <h3>${data.data?.value?.title ?? ''}</h3>
                      <p>${data.data?.value?.descriptionOne ?? ''}</p>
                      <p>${data.data?.value?.descriptionTwo ?? ''}</p>
                    </div>
                ''',
                onLoadingBuilder: (_, _, _) {
                  return _buildPlaceholder;
                },
              );
            },
            error: (error, _) {
              return EmptyWidget(
                replaceDefault: false,
                emptyBuilder: (context) {
                  return RetryButtons.scrollView(
                    error,
                    onRetry: () => ref.refresh(_termsConditionProvider),
                  );
                },
              );
            },
            loading: () => _buildPlaceholder,
          ),
        ),
      ),
    );
  }

  Widget get _buildPlaceholder {
    return Skeletonizer(
      child: HtmlWidget(
        '''
 <h3>Heading</h3>
<p>
    A paragraph with <strong>strong</strong>, <em>emphasized</em>
    and <span style="color: red">colored</span> text.
</p>
<h3>Heading</h3>
<p>
    A paragraph with <strong>strong</strong>, <em>emphasized</em>
    and <span style="color: red">colored</span> text.
</p>
<h3>Heading</h3>
<p>
    A paragraph with <strong>strong</strong>, <em>emphasized</em>
    and <span style="color: red">colored</span> text.
</p>
<h3>Heading</h3>
<p>
    A paragraph with <strong>strong</strong>, <em>emphasized</em>
    and <span style="color: red">colored</span> text.
</p>
<h3>Heading</h3>
  ''',
      ),
    );
  }
}

final _termsConditionProvider = FutureProvider<SummerNoteModel2>(
  (ref) => Future.microtask(ref.read(commonRepoProvider).getTermsCondition),
);
