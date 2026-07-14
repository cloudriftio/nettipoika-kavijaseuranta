import React from 'react'
import * as api from '../../api'
import * as url from '../../util/url'

import * as metrics from '../reports/metrics'
import ListReport from '../reports/list'
import { useSiteContext } from '../../site-context'
import { useQueryContext } from '../../query-context'
import { conversionsRoute } from '../../router'
import { t } from '../../../i18n'

export default function Conversions({ afterFetchData, onGoalFilterClick }) {
  const site = useSiteContext()
  const { query } = useQueryContext()

  function fetchConversions() {
    return api.get(url.apiPath(site, '/conversions'), query, { limit: 9 })
  }

  function getFilterInfo(listItem) {
    return {
      prefix: 'goal',
      filter: ['is', 'goal', [listItem.name]]
    }
  }

  function chooseMetrics() {
    return [
      metrics.createVisitors({
        renderLabel: (_query) => t('uniques'),
        meta: { plot: true }
      }),
      metrics.createEvents({
        renderLabel: (_query) => t('total'),
        meta: { hiddenOnMobile: true }
      }),
      metrics.createConversionRate(),
      BUILD_EXTRA &&
        metrics.createTotalRevenue({ meta: { hiddenOnMobile: true } }),
      BUILD_EXTRA &&
        metrics.createAverageRevenue({ meta: { hiddenOnMobile: true } })
    ].filter((metric) => !!metric)
  }

  /*global BUILD_EXTRA*/
  return (
    <ListReport
      fetchData={fetchConversions}
      afterFetchData={afterFetchData}
      getFilterInfo={getFilterInfo}
      keyLabel={t('goal')}
      onClick={onGoalFilterClick}
      metrics={chooseMetrics()}
      detailsLinkProps={{
        path: conversionsRoute.path,
        search: (search) => search
      }}
      color="bg-red-50 group-hover/row:bg-red-100"
      colMinWidth={90}
    />
  )
}
