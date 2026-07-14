import React from 'react'
import { SavedSegmentPublic, SavedSegment } from '../filtering/segments'
import { dateForSite, formatDayShort } from '../util/date'
import { useSiteContext } from '../site-context'
import { t } from '../../i18n'

type SegmentAuthorshipProps = {
  className?: string
  showOnlyPublicData: boolean
  segment: SavedSegmentPublic | SavedSegment
}

export function SegmentAuthorship({
  className,
  showOnlyPublicData,
  segment
}: SegmentAuthorshipProps) {
  const site = useSiteContext()
  const authorLabel =
    showOnlyPublicData === true
      ? null
      : (segment.owner_name ?? t('removedUser'))

  const { updated_at, inserted_at } = segment
  const showUpdatedAt = updated_at !== inserted_at

  return (
    <div className={className}>
      <div>
        {t('createdAt', {
          date: formatDayShort(dateForSite(inserted_at, site))
        })}
        {!showUpdatedAt &&
          !!authorLabel &&
          ` ${t('byAuthor', { author: authorLabel })}`}
      </div>
      {showUpdatedAt && (
        <div>
          {t('updatedAt', {
            date: formatDayShort(dateForSite(updated_at, site))
          })}
          {!!authorLabel && ` ${t('byAuthor', { author: authorLabel })}`}
        </div>
      )}
    </div>
  )
}
