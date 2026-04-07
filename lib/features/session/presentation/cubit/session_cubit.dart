import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/session_repository.dart';

// States
abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionLoaded extends SessionState {
  final SessionEntity? session;

  const SessionLoaded(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class SessionCubit extends Cubit<SessionState> {
  final SessionRepository _sessionRepository;
  StreamSubscription? _sessionSubscription;

  SessionCubit(this._sessionRepository) : super(SessionInitial());

  void loadCurrentSession() {
    emit(SessionLoading());
    _sessionSubscription?.cancel();
    _sessionSubscription = _sessionRepository.currentSessionStream.listen(
      (session) {
        emit(SessionLoaded(session));
      },
      onError: (error) {
        emit(SessionError(error.toString()));
      },
    );
  }

  Future<void> createSession() async {
    try {
      await _sessionRepository.createSession();
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> openSession(String sessionId) async {
    try {
      await _sessionRepository.openSession(sessionId);
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> closeSession(String sessionId) async {
    try {
      await _sessionRepository.closeSession(sessionId);
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> markDelivered(String sessionId) async {
    try {
      await _sessionRepository.markSessionDelivered(sessionId);
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> setDeliveryFee(String sessionId, double fee) async {
    try {
      await _sessionRepository.setDeliveryFee(sessionId, fee);
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> setTotalBill(String sessionId, double bill) async {
    try {
      await _sessionRepository.setTotalBill(sessionId, bill);
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  SessionEntity? get currentSession {
    final state = this.state;
    if (state is SessionLoaded) {
      return state.session;
    }
    return null;
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    return super.close();
  }
}
