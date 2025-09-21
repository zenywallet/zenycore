# Copyright (c) 2019 zenywallet

type
  DbStatus* {.pure.} = enum
    Success = 0
    Error
    NotFound

  DbResult*[T] = object
    case err*: DbStatus
    of DbStatus.Success:
      res*: T
    of DbStatus.Error:
      discard
    of DbStatus.NotFound:
      discard

  DbError* = object of CatchableError
