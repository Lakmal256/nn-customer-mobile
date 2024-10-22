import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:nawa_niwasa/locator.dart';
import 'package:nawa_niwasa/service/service.dart';

import '../../l10n.dart';
import '../ui.dart';

class MyJobsView extends StatefulWidget {
  const MyJobsView({super.key});

  @override
  State<MyJobsView> createState() => _MyJobsViewState();
}

enum SampleItem { itemOne, itemTwo, itemThree }

class _MyJobsViewState extends State<MyJobsView> {
  JobTypeDto? jobTypeFilterValue;
  String stringFilterValue = "";

  handleCreate(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const StandaloneJobFormView();
    }));
    fetchMyJobs();
  }

  fetchMyJobs() async {
    final user = locate<UserService>().value!;
    var types = await locate<RestService>().getAllJobTypes();
    var jobs = await locate<RestService>().getAllMyJobs(user.data.email!);
    jobs = (jobs ?? [])..sort((i0, i1) => i1.id!.compareTo(i0.id!));
    locate<MyJobPostsValueNotifier>()
      ..setTypes(types)
      ..setData(jobs);
  }

  @override
  void initState() {
    fetchMyJobs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
            child: Text(
              // "JOB LIST",
              AppLocalizations.of(context)!.nN_149.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      cursorColor: Colors.red,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        // hintText: 'SEARCH',
                        hintText: AppLocalizations.of(context)!.nN_175,
                        isDense: true,
                      ),
                      onChanged: (value) => setState(() {
                        stringFilterValue = value;
                      }),
                    ),
                  ),
                  PopupMenuButton<JobTypeDto>(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    position: PopupMenuPosition.over,
                    initialValue: jobTypeFilterValue,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(Icons.tune_rounded),
                    ),
                    onSelected: (JobTypeDto item) {
                      setState(() {
                        if (item.jobTypeName == "__null__") return jobTypeFilterValue = null;
                        jobTypeFilterValue = item;
                      });
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<JobTypeDto>(
                        value: JobTypeDto.empty()..jobTypeName = "__null__",
                        child: const Text("All"),
                      ),
                      ...locate<MyJobPostsValueNotifier>()
                          .value
                          .types
                          .map((value) => PopupMenuItem<JobTypeDto>(
                                value: value,
                                child: Text(value.jobTypeName ?? "N/A"),
                              ))
                          .toList()
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 10, right: 20),
            child: FilledButton(
              onPressed: () => handleCreate(context),
              style: ButtonStyle(
                visualDensity: VisualDensity.standard,
                textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w500)),
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                backgroundColor: MaterialStateProperty.all(AppColors.red),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
              // child: const Text("Create new job"),
              child: Text(AppLocalizations.of(context)!.nN_070),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "All",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: locate<MyJobPostsValueNotifier>(),
              builder: (context, store, _) {
                if (store.data.isEmpty) {
                  return Center(
                    child: Text(
                      // "Your job list is empty",
                      AppLocalizations.of(context)!.nN_1037,
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => fetchMyJobs(),
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: .75,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    children: (store.data)
                        .where((value) => value.title!.toLowerCase().contains(stringFilterValue.toLowerCase()))
                        .where(
                            (value) => value.jobType == jobTypeFilterValue?.jobTypeName || jobTypeFilterValue == null)
                        .map((value) => JobListItem(
                              onSelect: () => showStandaloneJobActionModalBottomSheet(
                                context,
                                job: value,
                                onChange: fetchMyJobs,
                              ),
                              slot1: value.location ?? "N/A",
                              slot2: '${value.id ?? "N/A"}',
                              slot3: value.jobType ?? "N/A",
                              slot4: value.title ?? "N/A",
                              slot5: value.jobDescription ?? "N/A",
                              slot6: value.sStatus ?? "N/A",
                              slot7: value.justDate,
                              slot8: locate<MyJobPostsValueNotifier>().getJobType(value).jobTypeImage ?? "",
                              slot9: value.accessibility == JobAccessibility.private
                                  ? AppLocalizations.of(context)!.nN_1069
                                  : AppLocalizations.of(context)!.nN_1070,
                              slot10: value.status,
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class JobService {
  JobService({required this.restService, required this.job});

  RestService restService;
  JobDto job;

  _handleError() {
    locate<PopupController>().addItemFor(
      DismissiblePopup(
        title: "Something went wrong",
        subtitle: "Sorry, something went wrong here",
        color: Colors.red,
        onDismiss: (self) => locate<PopupController>().removeItem(self),
      ),
      const Duration(seconds: 5),
    );
  }

  markAsDone() async {
    try {
      locate<ProgressIndicatorController>().show();
      await restService.markJobAsCompleted(job.id!);
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Successfully marked as completed",
          subtitle: "Successfully marked as completed",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } catch (err) {
      _handleError();
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }

  remove() async {
    try {
      locate<ProgressIndicatorController>().show();
      await restService.deleteJob(job.id!);
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Successfully deleted",
          subtitle: "Successfully deleted",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } catch (err) {
      _handleError();
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }

  acceptRequest(int requestId) async {
    try {
      locate<ProgressIndicatorController>().show();
      await restService.acceptJobRequest(requestId);
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Successfully accepted",
          subtitle: "Successfully accepted the job request",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } catch (err) {
      _handleError();
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }

  rejectRequest(int requestId) async {
    try {
      locate<ProgressIndicatorController>().show();
      await restService.rejectJobRequest(requestId);
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Successfully denied",
          subtitle: "Successfully denied the job request",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } catch (err) {
      _handleError();
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }
}

showStandaloneJobActionModalBottomSheet(
  BuildContext context, {
  required JobDto job,
  required Function() onChange,
}) =>
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) => StandaloneJobActionCardView(job: job, onChange: onChange),
    );

class StandaloneJobActionCardView extends StatefulWidget {
  StandaloneJobActionCardView({super.key, required this.job, required this.onChange})
      : jobService = JobService(restService: locate<RestService>(), job: job);

  final JobService jobService;
  final JobDto job;
  final Function() onChange;

  @override
  State<StandaloneJobActionCardView> createState() => _StandaloneJobActionCardViewState();
}

class _StandaloneJobActionCardViewState extends State<StandaloneJobActionCardView> {
  late List<JobRequestDto> jobRequests;

  @override
  initState() {
    jobRequests = [];
    fetchJobRequests();
    super.initState();
  }

  Future fetchJobRequests() async {
    var list = await locate<RestService>().getAllJobRequests(widget.job.id!);
    setState(() {
      jobRequests = list;
    });
    return;
  }

  markAsDone(BuildContext context) async {
    var canProceed = await showConfirmationDialog(context, title: "Confirm the decision");
    if (canProceed == null || !canProceed) return;

    await widget.jobService.markAsDone();
    widget.onChange();

    /// Remove job modal bottom sheet
    if (context.mounted) Navigator.of(context).pop();

    if (context.mounted) {
      var rating = await showStarRaterModalBottomSheet(
        context,
        onLater: Navigator.of(context).pop,
      );
      if (rating == null) return;
      await locate<RestService>().rateJob(widget.job.id!, rating);
    }
  }

  removeJob(BuildContext context) async {
    var canProceed = await showConfirmationDialog(
      context,
      // title: "Are you sure you want to delete this job?",
      title: AppLocalizations.of(context)!.nN_162,
      // mainTitle: "Delete Action",
      mainTitle: AppLocalizations.of(context)!.nN_1071,
    );
    if (canProceed == null || !canProceed) return;

    await widget.jobService.remove();
    widget.onChange();

    /// Remove job modal bottom sheet
    if (context.mounted) Navigator.of(context).pop();
  }

  acceptJob(BuildContext context, JobRequestDto request) async {
    // "Confirm the decision"
    var canProceed = await showConfirmationDialog(context, title: AppLocalizations.of(context)!.nN_1072);
    if (canProceed == null || !canProceed) return;

    await widget.jobService.acceptRequest(request.id!);
    widget.onChange();

    /// Remove job modal bottom sheet
    if (context.mounted) Navigator.of(context).pop();
  }

  rejectJob(BuildContext context, JobRequestDto request) async {
    // "Confirm the decision"
    var canProceed = await showConfirmationDialog(context, title: AppLocalizations.of(context)!.nN_1072);
    if (canProceed == null || !canProceed) return;

    await widget.jobService.rejectRequest(request.id!);
    fetchJobRequests();
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFE8E8E8),
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: Text(widget.job.id.toString()),
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              SizedBox.square(
                dimension: 100,
                child: Image.network(
                  locate<MyJobPostsValueNotifier>().getJobType(widget.job).jobTypeImage ?? "",
                  errorBuilder: (context, _, __) => const FittedBox(
                    fit: BoxFit.fill,
                    child: Icon(
                      Icons.person,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.job.jobType ?? "N/A",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: const Color(0xFFDA4540),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  color: Color(0xFFDA4540),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.job.location ?? "N/A",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildJobRequests(BuildContext context) {
    if (widget.job.status == JobStatus.open) {
      if (jobRequests.isNotEmpty) {
        return Expanded(
          child: ListView.separated(
            itemCount: jobRequests.length,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            separatorBuilder: (context, i) => const SizedBox(height: 10),
            itemBuilder: (context, i) => JobRequestItem(
              request: jobRequests[i],
              onAccept: () => acceptJob(context, jobRequests[i]),
              onReject: () => rejectJob(context, jobRequests[i]),
              onViewProfile: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StandaloneBuilderProfileView(
                    nic: jobRequests[i].builder!.nicNumber!,
                    // mobile: jobRequests[i].builder!.contactNumber!,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    Widget actions = const SizedBox.shrink();
    Widget msgBtn = const SizedBox.shrink();

    if (widget.job.isPrivate && widget.job.assignedBuilder != null) {
      if (widget.job.status == JobStatus.pending ||
          widget.job.status == JobStatus.inProgress ||
          widget.job.status == JobStatus.completed ||
          widget.job.status == JobStatus.rejected) {
        msgBtn = Padding(
          padding: const EdgeInsets.only(left: 10),
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              GoRouter.of(context).push(Uri(
                path: '/chat',
                queryParameters: {
                  'id': widget.job.assignedBuilder!.id.toString(),
                  'name': widget.job.assignedBuilder!.displayName,
                },
              ).toString());
            },
            icon: const Icon(Icons.message_outlined),
            label: Text(AppLocalizations.of(context)!.nN_1080),
          ),
        );
      }
    }

    if (widget.job.status == JobStatus.inProgress) {
      actions = Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: _ActionButton(
              filled: true,
              onPressed: () => markAsDone(context),
              // text: "Job Done",
              text: AppLocalizations.of(context)!.nN_167,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              onPressed: () => removeJob(context),
              // text: "Remove Job",
              text: AppLocalizations.of(context)!.nN_159,
            ),
          ),
        ],
      );
    }

    if (widget.job.status == JobStatus.completed ||
        widget.job.status == JobStatus.rejected ||
        widget.job.status == JobStatus.pending ||
        jobRequests.isEmpty && widget.job.status == JobStatus.open) {
      actions = _ActionButton(
        onPressed: () => removeJob(context),
        // text: "Remove Job",
        text: AppLocalizations.of(context)!.nN_159,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: buildHeader(context),
        ),
        const SizedBox(height: 10),
        buildJobRequests(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: Text(widget.job.jobDescription ?? "N/A")),
              msgBtn,
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: JobStatusIndicator(
            status: widget.job.status,
            text: widget.job.sStatus ?? "",
            extra: Text(widget.job.justDate),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: actions,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class JobRequestItem extends StatelessWidget {
  const JobRequestItem({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onViewProfile,
  });

  final JobRequestDto request;
  final Function() onAccept;
  final Function() onReject;
  final Function() onViewProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Text("${request.builder?.displayName} has applied for the job"),
        Text(AppLocalizations.of(context)!.nN_163(request.builder?.displayName ?? "")),
        GestureDetector(
          onTap: onViewProfile,
          child: Text(
            // "View Profile",
            AppLocalizations.of(context)!.nN_166,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                filled: true,
                onPressed: onAccept,
                // Accept
                text: AppLocalizations.of(context)!.nN_164,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                onPressed: onReject,
                // text: "Deny",
                text: AppLocalizations.of(context)!.nN_165,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onPressed,
    required this.text,
    this.filled = false,
  });

  final Function() onPressed;
  final String text;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    Color color = const Color(0xFF7F7F7F);

    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w500)),
          minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
          backgroundColor: MaterialStateProperty.all(AppColors.red),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      );
    }

    return OutlinedButton(
      style: ButtonStyle(
        padding: const MaterialStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        ),
        side: MaterialStatePropertyAll(
          BorderSide(width: 2, color: color),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

showStarRaterModalBottomSheet(
  BuildContext context, {
  required Function() onLater,
  double initialRating = 5.0,
}) =>
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => JobStarRaterView(
        onLater: onLater,
        onRate: (value) => Navigator.of(context).pop(value),
        initialRating: initialRating,
      ),
    );

class JobStarRaterView extends StatefulWidget {
  const JobStarRaterView({
    super.key,
    required this.onLater,
    required this.onRate,
    required this.initialRating,
  });

  final Function() onLater;
  final Function(double) onRate;
  final double initialRating;

  @override
  State<JobStarRaterView> createState() => _JobStarRaterViewState();
}

class _JobStarRaterViewState extends State<JobStarRaterView> {
  late double value;

  @override
  void initState() {
    value = widget.initialRating;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFE8E8E8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    // "How was quality of the work?",
                    AppLocalizations.of(context)!.nN_171,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 25),
                  RatingBar.builder(
                    initialRating: widget.initialRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        value = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  FilledButton(
                    onPressed: () => widget.onRate(value),
                    style: ButtonStyle(
                      visualDensity: VisualDensity.standard,
                      textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w500)),
                      minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                      backgroundColor: MaterialStateProperty.all(AppColors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ),
                    child: Text(
                      // "Submit",
                      AppLocalizations.of(context)!.nN_193,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: widget.onLater,
              child: Container(
                color: Colors.black12,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    // "Maybe Later",
                    AppLocalizations.of(context)!.nN_172,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showConfirmationDialog(BuildContext context, {required String title, String? mainTitle}) =>
    showDialog<bool>(
        context: context,
        builder: (context) => ConfirmationDialogView(
              title: title,
              mainTitle: mainTitle,
              onOk: () => Navigator.of(context).pop(true),
              onCancel: () => Navigator.of(context).pop(false),
            ));

class ConfirmationDialogView extends StatelessWidget {
  const ConfirmationDialogView({
    super.key,
    required this.title,
    required this.onOk,
    required this.onCancel,
    this.mainTitle,
  });

  final String? mainTitle;
  final String title;
  final Function() onOk;
  final Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          clipBehavior: Clip.antiAlias,
          constraints: const BoxConstraints.tightFor(width: double.maxFinite),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mainTitle != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                  ),
                  child: Text(
                    mainTitle!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              IntrinsicHeight(
                child: SizedBox(
                  height: 70,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onOk,
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              // "Yes",
                              AppLocalizations.of(context)!.nN_169,
                              style: const TextStyle(
                                color: AppColors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: GestureDetector(
                          onTap: onCancel,
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              // "No",
                              AppLocalizations.of(context)!.nN_170,
                              style: const TextStyle(color: Colors.black54),
                            ),
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
      ),
    );
  }
}

// Future showJobTypeFilterDialog(BuildContext context, { List<JobTypeDto>? types = const [], JobTypeDto? value}) => showMenu(context: context, position: position, items: )
