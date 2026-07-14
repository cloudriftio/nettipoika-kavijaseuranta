import React, { useCallback } from 'react'
import Modal from './modal'
import {
  hasConversionGoalFilter,
  isRealTimeDashboard
} from '../../util/filters'
import { addFilter, revenueAvailable } from '../../query'
import BreakdownModal from './breakdown-modal'
import * as metrics from '../reports/metrics'
import * as url from '../../util/url'
import { useQueryContext } from '../../query-context'
import { useSiteContext } from '../../site-context'
import { SortDirection } from '../../hooks/use-order-by'
import { t } from '../../../i18n'

function EntryPagesModal() {
  const { query } = useQueryContext()
  const site = useSiteContext()

  /*global BUILD_EXTRA*/
  const showRevenueMetrics = BUILD_EXTRA && revenueAvailable(query, site)

  const reportInfo = {
    title: t('entryPages'),
    dimension: 'entry_page',
    endpoint: url.apiPath(site, '/entry-pages'),
    dimensionLabel: t('entryPage'),
    defaultOrder: ['visitors', SortDirection.desc]
  }

  const getFilterInfo = useCallback(
    (listItem) => {
      return {
        prefix: reportInfo.dimension,
        filter: ['is', reportInfo.dimension, [listItem.name]]
      }
    },
    [reportInfo.dimension]
  )

  const addSearchFilter = useCallback(
    (query, searchString) => {
      return addFilter(query, [
        'contains',
        reportInfo.dimension,
        [searchString],
        { case_sensitive: false }
      ])
    },
    [reportInfo.dimension]
  )

  function chooseMetrics() {
    if (hasConversionGoalFilter(query)) {
      return [
        metrics.createTotalVisitors(),
        metrics.createVisitors({
          renderLabel: (_query) => t('conversions'),
          width: 'w-28'
        }),
        metrics.createConversionRate(),
        showRevenueMetrics && metrics.createTotalRevenue(),
        showRevenueMetrics && metrics.createAverageRevenue()
      ].filter((metric) => !!metric)
    }

    if (isRealTimeDashboard(query)) {
      return [
        metrics.createVisitors({
          renderLabel: (_query) => t('currentVisitorsLabel'),
          width: 'w-32'
        })
      ]
    }

    return [
      metrics.createVisitors({ renderLabel: (_query) => t('visitors') }),
      metrics.createVisits({
        renderLabel: (_query) => t('totalEntrances'),
        width: 'w-32'
      }),
      metrics.createBounceRate(),
      metrics.createVisitDuration()
    ]
  }

  return (
    <Modal>
      <BreakdownModal
        reportInfo={reportInfo}
        metrics={chooseMetrics()}
        getFilterInfo={getFilterInfo}
        addSearchFilter={addSearchFilter}
      />
    </Modal>
  )
}

export default EntryPagesModal
