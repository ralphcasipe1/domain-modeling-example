module Reporting where

import Data.Foldable (fold)
import Data.Monoid (getSum)

import qualified Database as DB
import Project

data Report = Report
  { budgetProfit :: Money
  , netProfit :: Money
  , difference :: Money
  } deriving (Show, Eq)

instance Semigroup Report where
  (Report b1 a1 d1) <> (Report b2 a2 d2) =
    Report (b1 + b2) (a1 + a2) (d1 + d2)

instance Monoid Report where
  mempty = Report 0 0 0

calculateReport :: Budget -> [Transaction] -> Report
calculateReport budget transactions =
  Report
    { budgetProfit = budgetProfit'
    , netProfit = netProfit'
    , difference = netProfit'
    }
      where
        budgetProfit' = budgetIncome budget - budgetExpenditure budget
        netProfit' = getSum (foldMap asProfit transactions)
        asProfit (Sale m) = pure m
        asProfit (Purchase m) = pure (negate m)

calculateProjectReport :: Project ProjectId -> IO (Project Report)
calculateProjectReport  =
  traverse (\p -> calculateReport <$> DB.getBudget p <*> DB.getTransactions p)
  
accumulateProjectReport :: Project Report -> Report
accumulateProjectReport = fold 
