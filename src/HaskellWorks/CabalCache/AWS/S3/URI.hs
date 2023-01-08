{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}

module HaskellWorks.CabalCache.AWS.S3.URI
  ( S3Uri(..)
  ) where

import Control.Applicative        (Alternative(many), optional)
import Control.DeepSeq            (NFData)
import Control.Lens               ((^.))
import Data.Generics.Product.Any  (HasAny(the))
import Data.Text                  (Text)
import GHC.Generics               (Generic)

import qualified Data.Aeson                 as J
import qualified Data.Aeson.Types           as J
import qualified Data.Attoparsec.Combinator as DAC
import qualified Data.Attoparsec.Text       as DAT
import qualified Data.Text                  as T
import qualified Network.AWS.Data           as AWS
import qualified Network.AWS.S3             as AWS

data S3Uri = S3Uri
  { bucket    :: AWS.BucketName
  , objectKey :: AWS.ObjectKey
  } deriving (Show, Eq, Ord, Generic, NFData)

instance AWS.FromText S3Uri where
  parser = do
    _  <- DAT.string "s3://"
    bn <- AWS.BucketName . T.pack <$> DAC.many1 (DAT.satisfy (\c -> c /= '/' && c /= ' '))
    _  <- optional (DAT.char '/')
    ok <- AWS.ObjectKey . T.pack <$> many DAT.anyChar
    DAT.endOfInput
    return (S3Uri bn ok)

instance AWS.ToText S3Uri where
  toText loc = toS3Uri (loc ^. the @"bucket") (loc ^. the @"objectKey")

instance J.ToJSON S3Uri where
  toJSON s3Uri = J.String (AWS.toText s3Uri)

instance J.FromJSON S3Uri where
  parseJSON v = case v of
    J.String s -> case AWS.fromText s of
      Right s3Uri -> return s3Uri
      Left msg    -> J.typeMismatch ("S3Uri (" <> msg <> ")") v
    _ -> J.typeMismatch "S3Uri" v

toS3Uri :: AWS.BucketName -> AWS.ObjectKey -> Text
toS3Uri (AWS.BucketName b) (AWS.ObjectKey k) = "s3://" <> b <> "/" <> k
