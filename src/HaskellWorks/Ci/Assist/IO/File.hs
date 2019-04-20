module HaskellWorks.Ci.Assist.IO.File
  ( copyDirectoryRecursive
  ) where

import Control.Monad.Except
import Control.Monad.IO.Class

import qualified System.Exit    as IO
import qualified System.IO      as IO
import qualified System.Process as IO

copyDirectoryRecursive :: MonadIO m => FilePath -> FilePath -> ExceptT String m ()
copyDirectoryRecursive source target = do
  process <- liftIO $ IO.spawnProcess "cp" ["-r", source, target]
  exitCode <- liftIO $ IO.waitForProcess process
  case exitCode of
    IO.ExitSuccess   -> return ()
    IO.ExitFailure n -> throwError ""
