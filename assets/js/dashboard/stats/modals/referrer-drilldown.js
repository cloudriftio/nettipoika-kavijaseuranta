import React, { useCallback } from 'react'
import { useParams } from 'react-router-dom'

import Modal from './modal'
import {
  hasConversionGoalFilter,
  isRealTimeDashboard
} from '../../util/filters'
import BreakdownModal from './breakdown-modal'
import * as metrics from '../reports/metrics'
import * as url from '../../util/url'
import { addFilter, revenueAvailable } from '../../query'
import { useQueryContext } from '../../query-context'
import { useSiteContext } from '../../site-context'
import { SortDirection } from '../../hooks/use-order-by'
import { SourceFavicon } from '../sources/source-favicon'
import { t } from '../../../i18n'

function ReferrerDrilldownModal() {
  const { referrer } = useParams()
  const { query } = useQueryContext()
  const site = useSiteContext()

  /*global BUILD_EXTRA*/
  const showRevenueMetrics = BUILD_EXTRA && revenueAvailable(query, site)

  const reportInfo = {
    title: t('referrerDrilldown'),
    dimension: 'referrer',
    endpoint: url.apiPath(
      site,
      `/referrers/${url.maybeEncodeRouteParam(referrer)}`
    ),
    dimensionLabel: t('referrer'),
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
      metrics.createBounceRate(),
      metrics.createVisitDuration()
    ]
  }

  const renderIcon = useCallback((listItem) => {
    return (
      <SourceFavicon
        name={listItem.name}
        className="size-4 mr-2 align-middle inline"
      />
    )
  }, [])

  const getExternalLinkURL = useCallback((listItem) => {
    if (listItem.name !== 'Direct / None') {
      return '//' + listItem.name
    }
  }, [])

  return (
    <Modal>
      <BreakdownModal
        reportInfo={reportInfo}
        metrics={chooseMetrics()}
        getFilterInfo={getFilterInfo}
        addSearchFilter={addSearchFilter}
        renderIcon={renderIcon}
        getExternalLinkURL={getExternalLinkURL}
      />
    </Modal>
  )
}

export default ReferrerDrilldownModal
