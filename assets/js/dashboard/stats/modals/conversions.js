import React, { useCallback, useState } from 'react'

import Modal from './modal'
import BreakdownModal from './breakdown-modal'
import * as metrics from '../reports/metrics'
import * as url from '../../util/url'
import { useSiteContext } from '../../site-context'
import { addFilter } from '../../query'
import { t } from '../../../i18n'

/*global BUILD_EXTRA*/
function ConversionsModal() {
  const [showRevenue, setShowRevenue] = useState(false)
  const site = useSiteContext()

  const reportInfo = {
    title: t('goalConversions'),
    dimension: 'goal',
    endpoint: url.apiPath(site, '/conversions'),
    dimensionLabel: t('goal')
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
    return [
      metrics.createVisitors({ renderLabel: (_query) => t('uniques') }),
      metrics.createEvents({ renderLabel: (_query) => t('total') }),
      metrics.createConversionRate(),
      showRevenue && metrics.createAverageRevenue(),
      showRevenue && metrics.createTotalRevenue()
    ].filter((metric) => !!metric)
  }

  // After a successful API response, we want to scan the rows of the
  // response and update the internal `showRevenue` state, which decides
  // whether revenue metrics are passed into BreakdownModal in `metrics`.
  const afterFetchData = useCallback((res) => {
    setShowRevenue(revenueInResponse(res))
  }, [])

  // After fetching the next page, we never want to set `showRevenue` to
  // `false` as revenue metrics might exist in previously loaded data.
  const afterFetchNextPage = useCallback(
    (res) => {
      if (!showRevenue && revenueInResponse(res)) {
        setShowRevenue(true)
      }
    },
    [showRevenue]
  )

  function revenueInResponse(apiResponse) {
    return apiResponse.results.some((item) => item.total_revenue)
  }

  return (
    <Modal>
      <BreakdownModal
        reportInfo={reportInfo}
        metrics={chooseMetrics()}
        afterFetchData={BUILD_EXTRA ? afterFetchData : undefined}
        afterFetchNextPage={BUILD_EXTRA ? afterFetchNextPage : undefined}
        getFilterInfo={getFilterInfo}
        addSearchFilter={addSearchFilter}
      />
    </Modal>
  )
}

export default ConversionsModal
