import React, { useCallback } from 'react'

import Modal from './modal'
import { hasConversionGoalFilter } from '../../util/filters'
import BreakdownModal from './breakdown-modal'
import * as metrics from '../reports/metrics'
import * as url from '../../util/url'
import { useQueryContext } from '../../query-context'
import { useSiteContext } from '../../site-context'
import { addFilter, revenueAvailable } from '../../query'
import { SortDirection } from '../../hooks/use-order-by'
import { t } from '../../../i18n'

const VIEWS = {
  countries: {
    title: t('topCountries'),
    dimension: 'country',
    endpoint: '/countries',
    dimensionLabel: t('country'),
    defaultOrder: ['visitors', SortDirection.desc]
  },
  regions: {
    title: t('topRegions'),
    dimension: 'region',
    endpoint: '/regions',
    dimensionLabel: t('region'),
    defaultOrder: ['visitors', SortDirection.desc]
  },
  cities: {
    title: t('topCities'),
    dimension: 'city',
    endpoint: '/cities',
    dimensionLabel: t('city'),
    defaultOrder: ['visitors', SortDirection.desc]
  }
}

function LocationsModal({ currentView }) {
  const { query } = useQueryContext()
  const site = useSiteContext()

  /*global BUILD_EXTRA*/
  const showRevenueMetrics = BUILD_EXTRA && revenueAvailable(query, site)

  let reportInfo = VIEWS[currentView]
  reportInfo = {
    ...reportInfo,
    endpoint: url.apiPath(site, reportInfo.endpoint)
  }

  const getFilterInfo = useCallback(
    (listItem) => {
      return {
        prefix: reportInfo.dimension,
        filter: ['is', reportInfo.dimension, [listItem.code]],
        labels: { [listItem.code]: listItem.name }
      }
    },
    [reportInfo.dimension]
  )

  const addSearchFilter = useCallback(
    (query, searchString) => {
      return addFilter(query, [
        'contains',
        `${reportInfo.dimension}_name`,
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

    if (query.period === 'realtime') {
      return [
        metrics.createVisitors({
          renderLabel: (_query) => t('currentVisitorsLabel'),
          width: 'w-32'
        })
      ]
    }

    return [
      metrics.createVisitors({ renderLabel: (_query) => t('visitors') }),
      currentView === 'countries' && metrics.createPercentage()
    ].filter((metric) => !!metric)
  }

  const renderIcon = useCallback((listItem) => {
    return (
      <span className="mr-1">{listItem.country_flag || listItem.flag}</span>
    )
  }, [])

  return (
    <Modal>
      <BreakdownModal
        reportInfo={reportInfo}
        metrics={chooseMetrics()}
        getFilterInfo={getFilterInfo}
        renderIcon={renderIcon}
        addSearchFilter={addSearchFilter}
      />
    </Modal>
  )
}

export default LocationsModal
